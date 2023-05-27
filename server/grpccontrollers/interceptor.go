package grpccontrollers

import (
	"context"
	"encoding/base64"
	"errors"
	"fmt"
	"log"
	"strings"
	"sync"
	"time"

	pb "univex.com/wegpt/chatmessage"
	"univex.com/wegpt/repository"

	"github.com/golang-jwt/jwt"
	"golang.org/x/time/rate"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/proto"
	"gorm.io/gorm"
	"univex.com/wegpt/models"
	"univex.com/wegpt/wegpt"
)

type RateAuthLimiterInterceptor struct {
	mtx          sync.Mutex
	limiter      *rate.Limiter
	queue        chan struct{}
	queueSize    int
	maxQueueSize int
}

func NewRateAuthLimiterInterceptor(rateLimit int, maxQueueSize int) *RateAuthLimiterInterceptor {
	return &RateAuthLimiterInterceptor{
		limiter:      rate.NewLimiter(rate.Limit(rateLimit), rateLimit),
		queue:        make(chan struct{}, maxQueueSize),
		queueSize:    0,
		maxQueueSize: maxQueueSize,
	}
}

func verifyToken(tokenString string) (int, error) {
	_tokenString := strings.ReplaceAll(tokenString, "Bearer ", "")
	_secret, err := jwt.Parse(_tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(wegpt.PrivateSigningKey), nil
	})
	if err != nil {
		return -1, fmt.Errorf("invalidate token")
	}
	if !_secret.Valid {
		return -1, fmt.Errorf("invalidate token")
	}
	claims := _secret.Claims.(jwt.MapClaims)
	user_id := uint(claims["userId"].(float64))
	if _, ok := models.TokenMaps[user_id]; !ok {
		if err := models.GetDB().Where("token = ?", _tokenString).Take(&models.Token{}).Error; errors.Is(err, gorm.ErrRecordNotFound) {
			go SynTokenUsage(user_id)
			return -1, fmt.Errorf("invalidate token")
		}
		var tuser *repository.User
		if err := models.GetDB().Where("id = ?", user_id).Take(&tuser).Error; err == nil {
			models.TokenMaps[user_id] = *tuser.Convert()
		}
		return int(user_id), nil
	}
	return int(user_id), nil
}

func verifySecret(secretKey string) error {
	_secretKey := strings.ReplaceAll(secretKey, "Buller ", "")
	_secret, err := jwt.Parse(_secretKey, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(wegpt.PrivateSigningKey), nil
	})
	if err != nil {
		return err
	}

	if err != nil {
		return err
	}

	if claims, ok := _secret.Claims.(jwt.MapClaims); ok && _secret.Valid {
		_time, ok := claims["time"].(float64)
		if !ok {
			return fmt.Errorf("invalid secret")
		}

		if time.Now().Unix()-int64(_time) >= 30 {
			return fmt.Errorf("secret has expired")
		}
		return nil
	}

	return fmt.Errorf("invalid secret")
}

func sendHeaderInfo(stream grpc.ServerStream, status uint32, message string) {
	headerMessage := &pb.HeaderMessage{}
	headerMessage.Status = status
	headerMessage.Message = message
	headerData, _ := proto.Marshal(headerMessage)
	header := metadata.New(map[string]string{
		"Authentication": base64.StdEncoding.EncodeToString(headerData),
	})
	if err := stream.SendHeader(header); err != nil {
		log.Println(err)
	}
}

func (r *RateAuthLimiterInterceptor) processQueue() {

	for {
		r.mtx.Lock()
		if r.queueSize == 0 {
			r.mtx.Unlock()
			return // 当队列为空时退出协程
		}
		<-r.queue
		r.queueSize--
		r.mtx.Unlock()
		r.limiter.Wait(context.Background()) // 等待下一个令牌可用
	}
}

func (r *RateAuthLimiterInterceptor) StreamInterceptor(srv interface{}, stream grpc.ServerStream,
	_ *grpc.StreamServerInfo, handler grpc.StreamHandler) (err error) {
	defer func() {
		if r := recover(); r != nil {
			log.Printf("Recovered from panic: %v", r)
			err = status.Errorf(codes.Internal, "服务器内部错误!")
		}
	}()

	token, secretKey, err := getTokenFromHeader(stream.Context())
	if err != nil {
		return err
	}
	userId, err := verifyToken(token)
	if err != nil {
		sendHeaderInfo(stream, 1, "登录过期")
		return err

	}
	if err := verifySecret(secretKey); err != nil {
		sendHeaderInfo(stream, 2, "Secret 过期，请稍后重试！")
		return err

	}

	if userId > 0 {
		dayToken, ok := UsageTokens[uint(userId)]
		if ok {
			if time.Now().After(dayToken.Date) {
				resetTokenRemain(uint(userId), dayToken.TokensRemain)
			} else {
				if dayToken.TokensRemain <= 0 {
					sendHeaderInfo(stream, 3, "使用超量，明日回复之后可继续...")
					resetTokenRemain(uint(userId), dayToken.TokensRemain)
					return err
				}
			}
		} else {
			dayToken, err := resetTokenRemain(uint(userId), OneDayMaxTokens)
			if err != nil {
				sendHeaderInfo(stream, 4, "服务器出现错误,请稍后重试...")
				return err
			}
			if dayToken.TokensRemain <= 0 {
				sendHeaderInfo(stream, 3, "使用超量，明日回复之后可继续...")
				return err
			}
		}
		if user, ok := models.TokenMaps[uint(userId)]; ok {
			if !user.IsVip {
				if user.FreeUsage > 0 {
					models.TokenMaps[uint(userId)] = user
				} else {
					sendHeaderInfo(stream, 5, "免费消息已经使用完,请联系客服进行充值。")
					return fmt.Errorf("free usage is done")
				}
			}
		}
	}
	sendHeaderInfo(stream, 0, "")
	r.mtx.Lock()
	r.limiter.Wait(context.Background())
	if !r.limiter.Allow() {
		if r.queueSize < r.maxQueueSize {
			r.queue <- struct{}{}
			r.queueSize++
			go r.processQueue()
		} else {
			r.mtx.Unlock()
			sendHeaderInfo(stream, 3, "访问人数太多，请稍后重试.....")
			return fmt.Errorf("rate limit")
		}
	}

	r.mtx.Unlock()
	ctx := context.WithValue(stream.Context(), UserIDKey, uint(userId))
	err = handler(srv, &authStream{stream, ctx})
	return err
}

func resetTokenRemain(userId uint, tokenReamin int) (*models.OneDayToken, error) {
	tokenUsage := models.TokenUsage{}
	if err := models.GetDB().Where("user_id = ?", userId).Find(&tokenUsage).Error; err != nil {
		fmt.Printf("%+v重置出错\n", userId)
		return nil, err
	}

	tokenUsage.UserId = userId
	oneDayTokens := models.OneDayToken{}
	now := time.Now()
	resetDate := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	resetDate = resetDate.Add(time.Hour * 24)
	if now.After(tokenUsage.ResetDate) {

		oneDayTokens.Date = resetDate
		oneDayTokens.TokensRemain = OneDayMaxTokens
		UsageTokens[userId] = oneDayTokens
		tokenUsage.ResetDate = resetDate.Add(time.Hour * 24 * 29)
	} else {
		tokenUsage.TokenUsed += (OneDayMaxTokens - tokenReamin)
		if tokenUsage.TokenUsed >= OneMonthMaxTokens {
			return nil, fmt.Errorf("本月数据已经使用完！")
		}
		nowDate := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
		usedDays := 30 - int(tokenUsage.ResetDate.Sub(nowDate).Hours()/24)
		maxTokens := (usedDays*OneDayMaxTokens - tokenUsage.TokenUsed)
		oneDayTokens.Date = resetDate
		oneDayTokens.TokensRemain = maxTokens
		UsageTokens[userId] = oneDayTokens
	}
	if err := models.GetDB().Where("user_id = ?", userId).Save(&tokenUsage).Error; err != nil {
		fmt.Printf("%+v保存出错\n", userId)
		return nil, err
	}
	return &oneDayTokens, nil
}

func SynTokenUsage(userId uint) {
	if dayToken, ok := UsageTokens[userId]; ok {
		tokenUsage := models.TokenUsage{}
		if err := models.GetDB().Where("user_id = ?", userId).Find(&tokenUsage).Error; err == nil {
			tokenUsage.TokenUsed += (OneDayMaxTokens - dayToken.TokensRemain)
			if err := models.GetDB().Where("user_id = ?", userId).Save(&tokenUsage).Error; err == nil {
				delete(UsageTokens, userId)
			}
		}
	}
}

// 自定义 ServerStream，以便可以将新的上下文传递给流处理程序
type authStream struct {
	grpc.ServerStream
	ctx context.Context
}

func (s *authStream) Context() context.Context {
	return s.ctx
}

// 从请求头中获取 token
func getTokenFromHeader(ctx context.Context) (string, string, error) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return "", "", fmt.Errorf("missing metadata")
	}
	if len(md["authorization"]) == 0 {
		return "", "", fmt.Errorf("missing authorization token")
	}

	if len(md["secretkey"]) == 0 {
		return "", "", fmt.Errorf("missing SecretKey token")
	}
	return md["authorization"][0], md["secretkey"][0], nil
}
