package controllers

import (
	"crypto/sha256"
	"encoding/base64"
	"strconv"
	"time"

	"github.com/gofiber/fiber/v2"
	"univex.com/wegpt/models"
	"univex.com/wegpt/wegpt"
)

func GenerateInviteCode(c *fiber.Ctx) error {
	var status = fiber.StatusOK
	userId := wegpt.UserIDFromToken(c)
	if err := models.GetDB().Where("user_id = ?", userId).Delete(&models.InviteCode{}).Error; err != nil {
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Message: "邀请码生成失败", Status: status})
	}
	code := generateUniqueInviteCode(userId)
	inviteCode := models.InviteCode{UserId: userId, Code: code, CreatedAt: time.Now(), UpdatedAt: time.Now()}
	if err := models.GetDB().Create(&inviteCode).Error; err != nil {
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Message: "邀请码生成失败", Status: status})
	}
	return c.Status(status).JSON(models.RequestResult{Data: inviteCode, Status: status})
}

func generateUniqueInviteCode(userID uint) string {
	data := strconv.Itoa(int(userID)) + strconv.FormatInt(time.Now().UnixNano(), 10)
	hash := sha256.Sum256([]byte(data))
	truncatedHash := hash[:9]
	inviteCode := base64.RawURLEncoding.EncodeToString(truncatedHash)
	return inviteCode
}

func InviteCode(c *fiber.Ctx) error {
	var status = fiber.StatusOK
	userId := wegpt.UserIDFromToken(c)
	inviteCode := models.InviteCode{}
	if err := models.GetDB().Where("user_id = ?", userId).Take(&inviteCode).Error; err != nil {
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Message: "获取邀请码失败！", Status: status})
	}
	return c.Status(status).JSON(models.RequestResult{Data: inviteCode, Status: status})
}
