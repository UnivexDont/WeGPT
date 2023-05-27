package grpccontrollers

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"io"
	"log"
	"unicode"

	pb "univex.com/wegpt/chatmessage"
	"univex.com/wegpt/models"

	"github.com/sashabaranov/go-openai"
)

type GPTContextKey string

const UserIDKey GPTContextKey = "userID"

var (
	UsageTokens       = make(map[uint]models.OneDayToken, 0)
	OneDayMaxTokens   = 33000
	OneMonthMaxTokens = 1000000

	Port = flag.Int("port", 55551, "The server port")
	// 填写自己的OpenAI key
	openAIKey = ""
)

type Server struct {
	pb.UnimplementedChatMessagerServer
}

func (s *Server) SendMessage(in *pb.ChatMessageRequest, stream pb.ChatMessager_SendMessageServer) error {
	content := in.GetMessages()
	user := in.GetUser()
	c := openai.NewClient(openAIKey)
	ctx := context.Background()
	messages := make([]map[string]string, 0)
	err := json.Unmarshal(content, &messages)
	userId := stream.Context().Value(UserIDKey).(uint)
	usagetokens := UsageTokens[uint(userId)]
	if err != nil {
		return err
	}

	if user, ok := models.TokenMaps[uint(userId)]; ok {
		user.FreeUsage -= 1
		models.TokenMaps[uint(userId)] = user
		if user.FreeUsage == 0 {
			if err := models.GetDB().Table("users").Where("id = ?", userId).Update("free_usage", 0).Error; err != nil {
				log.Printf("%v-FreeUsage 更新失败！！！", userId)
			}
		}
	}

	cMessages := make([]openai.ChatCompletionMessage, 0)
	for _, message := range messages {
		messageStr := message["message"]
		id := message["id"]
		usagetokens.TokensRemain -= countTokens(messageStr + id)
		cMessages = append(cMessages, openai.ChatCompletionMessage{
			Role:    openai.ChatMessageRoleUser,
			Content: message["message"],
			Name:    message["id"],
		})
	}

	req := openai.ChatCompletionRequest{
		Model:       openai.GPT3Dot5Turbo,
		Messages:    cMessages,
		Temperature: 0.618,
		Stream:      true,
		User:        user,
	}
	openStream, err := c.CreateChatCompletionStream(ctx, req)
	if err != nil {
		log.Printf("ChatCompletionStream error: %v\n", err)
		return err
	}
	defer openStream.Close()
	finished := false
	responseTokens := 0

	for {
		response, err := openStream.Recv()
		if errors.Is(err, io.EOF) {
			finished = true
		} else if err != nil {
			log.Printf("\nStream error: %v\n", err)
			updateTokens(uint(userId), responseTokens, usagetokens)
			return err
		}
		message := ""
		if !finished {
			message = response.Choices[0].Delta.Content
			responseTokens += countTokens(message)
		}
		reply := &pb.ChatMessageReply{
			Message:  message,
			Id:       response.ID,
			Finished: finished,
			Login:    true,
		}
		if err := stream.Send(reply); err != nil {
			updateTokens(uint(userId), responseTokens, usagetokens)

			return err
		}
		if finished {
			updateTokens(uint(userId), responseTokens, usagetokens)
			return nil
		}
	}
}

func updateTokens(userId uint, responseTokens int, usagetokens models.OneDayToken) {
	usagetokens.TokensRemain -= responseTokens
	UsageTokens[userId] = usagetokens

}

func countTokens(text string) int {
	tokenCount := 0
	inWord := false

	for _, char := range text {
		if unicode.IsLetter(char) && unicode.Is(unicode.Latin, char) {
			if !inWord {
				inWord = true
				tokenCount++
			}
		} else {
			inWord = false
			if unicode.Is(unicode.Han, char) || unicode.IsPunct(char) {
				tokenCount++
			}
		}
	}

	return tokenCount
}

// 并发测试
// func (s *server) SendMessage(in *pb.ChatMessageRequest, stream pb.ChatMessager_SendMessageServer) error {
// 	content := in.GetMessages()
// 	messages := make([]map[string]string, 0)
// 	err := json.Unmarshal(content, &messages)

// 	if err != nil {
// 		return err
// 	}
// 	finished := false
// 	firstMessage := messages[0]
// 	mID := firstMessage["id"]
// 	fmt.Printf("第%+v个\n", mID)
// 	for i := 0; i < 1; i++ {

// 		message := ""
// 		if !finished {
// 			message = firstMessage["id"] + ":Message"
// 		}
// 		reply := &pb.ChatMessageReply{
// 			Message:  message,
// 			Id:       firstMessage["id"],
// 			Finished: finished,
// 			Login:    true,
// 		}
// 		if err := stream.Send(reply); err != nil {
// 			return err
// 		}
// 		if finished {
// 			return nil
// 		}
// 	}
// 	return nil

// }
