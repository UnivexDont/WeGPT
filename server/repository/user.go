package repository

import (
	"time"

	"gorm.io/gorm"
	"univex.com/wegpt/models"
)

type User struct {
	gorm.Model
	ID         uint      `json:"id"`
	Phone      string    `json:"phone"`
	Email      string    `json:"email"`
	InviterId  uint      `json:"inviterId"`
	IsVip      bool      `json:"isVip"`
	FreeUsage  int       `json:"freeUsage"`
	VipEndedAt time.Time `json:"vipEndedAt"`
}

func (u *User) Convert() *models.User {
	res := models.User{}
	res.ID = u.ID
	res.Email = u.Email
	res.Phone = u.Phone
	res.IsVip = u.IsVip
	res.FreeUsage = u.FreeUsage
	res.VipEndedAt = u.VipEndedAt
	return &res
}
