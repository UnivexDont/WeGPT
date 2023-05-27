package models

import "time"

type TokenUsage struct {
	UserId    uint      `json:"userId"`
	TokenUsed int       `json:"tokenUsed"`
	ResetDate time.Time `json:"resetDate"`
	CreatedAt time.Time `json:"createAt"`
}

type OneDayToken struct {
	TokensRemain int       `json:"tokenRemain"`
	Date         time.Time `json:"date"`
}
