package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	ID         uint      `json:"id"`
	Phone      string    `json:"phone"`
	Email      string    `json:"email"`
	IsVip      bool      `json:"isVip"`
	FreeUsage  int       `json:"freeUsage"`
	VipEndedAt time.Time `json:"vipEndedAt"`
}

type LoginInfo struct {
	gorm.Model
	Token    string `json:"token"`
	UserInfo User   `json:"userInfo"`
}

type LoginParam struct {
	Phone      string
	Email      string
	VerifyCode string
	InviteCode string
}

type Token struct {
	CreatedAt time.Time
	UpdatedAt time.Time
	Token     string `json:"token"`
	UserId    uint   `json:"userId" gorm:"column:user_id"`
}
