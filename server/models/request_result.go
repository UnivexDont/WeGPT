package models

type RequestResult struct {
	Status  int         `json:"status"`
	Code    string      `json:"code"`
	Data    interface{} `json:"data"`
	Message string      `json:"message"`
}

type PageResult struct {
	Total    int64       `json:"total"`
	List     interface{} `json:"list"`
	PageSize int         `json:"pageSize"`
	PageNo   int         `json:"pageNo"`
}
