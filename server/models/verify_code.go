package models

import "time"

type VerifyCode struct {
	Phone     string    `json:"phone" `
	Email     string    `json:"email"`
	Code      string    `json:"code"`
	Used      bool      `json:"used"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}
