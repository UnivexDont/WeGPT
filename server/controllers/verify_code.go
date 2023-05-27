package controllers

import (
	"bytes"
	"fmt"
	"log"
	"math/rand"
	"text/template"
	"time"

	"github.com/gofiber/fiber/v2"
	"gopkg.in/gomail.v2"
	"univex.com/wegpt/models"
	"univex.com/wegpt/wegpt"
)

type TemplateData struct {
	Code string
}

func EmailCode(c *fiber.Ctx) error {

	var status = fiber.StatusOK

	email := c.Params("email")
	if err := wegpt.AuthSecretKey(c); err != nil {
		status = fiber.StatusUnauthorized
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: err.Error()})
	}

	smsCode := models.VerifyCode{}
	if err := models.GetDB().Where("email = ?", email).Find(&smsCode).Error; err != nil {
		fmt.Println(err.Error())
		status = fiber.StatusBadRequest
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: "验证码生成出现错误！"})
	}

	if smsCode.Email == email {
		updatedAt := smsCode.UpdatedAt
		if time.Now().Unix()-updatedAt.Unix() <= 300 && !smsCode.Used {
			status = fiber.StatusConflict
			return c.Status(status).JSON(models.RequestResult{Status: status, Message: "验证码5分钟内不可重复请求！"})
		}
	} else {
		smsCode.Email = email
	}

	smsCode.Code = generateCode()
	smsCode.Used = false
	if err := models.GetDB().Where("email = ?", email).Save(&smsCode).Error; err != nil {
		log.Println(err.Error())
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: "验证码获取失败"})
	}

	from := "cibeai@foxmail.com"
	password := "qilxazcqfgpxbbgf"
	to := []string{"1204568865@qq.com"}
	subject := "Verification Code"
	t, err := template.ParseFiles("views/verify.html")
	if err != nil {
		log.Printf("Error:%+v\n", err)
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: "验证码获取失败"})
	}
	var tpl bytes.Buffer
	if err := t.Execute(&tpl, TemplateData{Code: smsCode.Code}); err != nil {
		log.Println("Error executing template:", err)
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: "验证码获取失败"})
	}

	m := gomail.NewMessage()
	m.SetHeader("From", from)
	m.SetHeader("To", to...)
	m.SetHeader("Subject", subject)
	m.SetBody("text/html", tpl.String())

	d := gomail.NewDialer("smtp.qq.com", 587, from, password)
	if err := d.DialAndSend(m); err != nil {
		status = fiber.StatusInternalServerError
		return c.Status(status).JSON(models.RequestResult{Status: status, Message: "验证码获取失败"})
	}
	return c.Status(status).JSON(models.RequestResult{Status: status, Message: "验证码获取成功"})
}

func generateCode() string {
	src := rand.NewSource(time.Now().UnixNano())
	r := rand.New(src)
	code := r.Intn(999999)
	return fmt.Sprintf("%06d", code)
}
