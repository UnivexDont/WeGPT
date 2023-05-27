package models

import "time"

type InviteCode struct {
	UserId    uint      `json:"userId"`
	Code      string    `json:"code"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}
