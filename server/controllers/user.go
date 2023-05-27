package controllers

import (
	"errors"
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v4"
	"gorm.io/gorm"
	"univex.com/wegpt/grpccontrollers"
	"univex.com/wegpt/models"
	"univex.com/wegpt/repository"
	"univex.com/wegpt/wegpt"
)

func _generateKey(usedId uint) (string, error) {
	claims := jwt.MapClaims{
		"userId": usedId,
		"admin":  true,
		"time":   time.Now().Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	t, err := token.SignedString([]byte(wegpt.PrivateSigningKey))
	return t, err
}

func Login(c *fiber.Ctx) error {
	var status = fiber.StatusOK
	if err := wegpt.AuthSecretKey(c); err != nil {
		var status = fiber.StatusForbidden
		return c.Status(fiber.StatusOK).JSON(models.RequestResult{Status: status, Message: err.Error()})
	}
	loginParam := new(models.LoginParam)
	if err := c.BodyParser(loginParam); err != nil {
		status = fiber.StatusOK
		return c.Status(fiber.StatusOK).JSON(models.RequestResult{Status: status, Message: "请求参数错误！！！"})
	}

	verifyCode := models.VerifyCode{}
	if err := models.GetDB().Where("email = ?", loginParam.Email).Take(&verifyCode).Error; err != nil {
		log.Println(err)
	}
	if len(verifyCode.Code) <= 0 {
		status = fiber.StatusNotAcceptable
		return c.Status(fiber.StatusOK).JSON(models.RequestResult{Status: status, Message: "请选输入登录验证码！"})
	}
	if verifyCode.Code != loginParam.VerifyCode || verifyCode.Used {
		status = fiber.StatusForbidden
		return c.Status(fiber.StatusOK).JSON(models.RequestResult{Status: status, Message: "请输入6位有效的验证码！"})
	}

	if time.Now().Unix()-verifyCode.UpdatedAt.Unix() > 300 {
		status = fiber.StatusForbidden
		return c.Status(fiber.StatusOK).JSON(models.RequestResult{Status: status, Message: "验证码已过期，请重新获取！"})
	}

	verifyCode.Used = true
	models.GetDB().Where("email = ?", loginParam.Email).Save(verifyCode)
	var tuser *repository.User
	if err := models.GetDB().Where("email = ?", loginParam.Email).Take(&tuser).Error; errors.Is(err, gorm.ErrRecordNotFound) {
		return Register(loginParam, c)
	} else if err != nil {
		status = fiber.StatusInternalServerError
		return c.Status(fiber.StatusOK).JSON(models.RequestResult{Status: status, Message: err.Error()})
	}

	if err := models.GetDB().Where("user_id = ?", tuser.ID).Delete(&models.Token{}).Error; err != nil {
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: err.Error()})
	}

	_token, _err := _generateKey(tuser.ID)
	if _err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(models.RequestResult{Status: status, Message: "登录失败"})
	}
	tokenModel := models.Token{CreatedAt: time.Now(), Token: _token, UserId: tuser.ID}
	if err := models.GetDB().Create(&tokenModel).Error; err != nil {
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: err.Error()})
	}
	tuser.Phone = loginParam.Phone
	user := tuser.Convert()
	models.TokenMaps[tuser.ID] = *user
	return c.Status(fiber.StatusOK).
		JSON(models.RequestResult{Status: status, Message: "登录成功", Data: models.LoginInfo{Token: _token, UserInfo: *user}})
}

func Register(loginParam *models.LoginParam, c *fiber.Ctx) error {
	var user repository.User
	var status = fiber.StatusOK
	if err := c.BodyParser(&user); err != nil {
		status = fiber.StatusBadRequest
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: err.Error()})
	}

	db := models.GetDB()
	inviteCode := models.InviteCode{}
	if err := models.GetDB().Where("code = ?", loginParam.InviteCode).Take(&inviteCode).Error; err == nil {
		user.InviterId = inviteCode.UserId
	} else {
		log.Printf("%v 查找不到", loginParam.InviteCode)
	}
	user.Phone = loginParam.Phone
	user.Email = loginParam.Email
	user.FreeUsage = 10

	user.VipEndedAt = time.Now()
	if err := db.Create(&user).Error; err != nil {
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: err.Error()})
	}
	_token, _err := _generateKey(user.ID)
	if _err != nil {
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: "注册失败"})
	}
	tokenModel := models.Token{CreatedAt: time.Now(), Token: _token, UserId: user.ID}
	if err := models.GetDB().Create(&tokenModel).Error; err != nil {
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: err.Error()})
	}
	resUser := user.Convert()
	models.TokenMaps[user.ID] = *resUser

	return c.Status(status).
		JSON(models.RequestResult{Status: status, Message: "注册成功", Data: models.LoginInfo{Token: _token, UserInfo: *resUser}})
}

func CancleAccount(c *fiber.Ctx) error {
	var status = fiber.StatusOK
	if err := wegpt.AuthSecretKey(c); err != nil {
		status = fiber.StatusForbidden
		return c.Status(fiber.StatusOK).JSON(models.RequestResult{Status: status, Message: "Screct 验证失败，账号注销失败！"})
	}
	userJwt := c.Locals("user").(*jwt.Token)
	claims := userJwt.Claims.(jwt.MapClaims)
	phone := claims["phone"].(string)
	user := models.User{Phone: phone}

	if err := models.GetDB().Where("phone = ?", phone).Delete(&user).Error; err != nil {
		status = fiber.StatusForbidden
		return c.Status(fiber.StatusOK).JSON(models.RequestResult{Status: status, Message: "账号注销失败，请稍后重试"})
	}
	return c.Status(fiber.StatusOK).JSON(models.RequestResult{Status: status, Message: "账号注销成功！"})

}

func Logout(c *fiber.Ctx) error {
	var status = fiber.StatusOK
	if err := wegpt.AuthSecretKey(c); err != nil {
		var status = fiber.StatusForbidden
		return c.Status(fiber.StatusOK).JSON(models.RequestResult{Status: status, Message: err.Error()})
	}
	userId := wegpt.UserIDFromToken(c)
	if err := models.GetDB().Where("user_id = ?", userId).Delete(&models.Token{}).Error; err != nil {
		log.Println("删除token 出现问题", userId)
	}
	delete(models.TokenMaps, userId)
	go grpccontrollers.SynTokenUsage(userId)
	return c.Status(fiber.StatusOK).
		JSON(models.RequestResult{Status: status, Message: "退出登录成功"})
}
