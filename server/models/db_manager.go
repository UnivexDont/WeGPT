package models

import (
	"fmt"
	"log"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"univex.com/wegpt/wegpt"
)

var TokenMaps = make(map[uint]User, 0)

var _db *gorm.DB
var _dberr error

func init() {
	dbConfig := wegpt.GetDataBaseConfig()
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/gpt_app?charset=utf8mb4&parseTime=True&loc=Local", dbConfig.User, dbConfig.Pass, dbConfig.Host, dbConfig.Port)
	_db, _dberr = gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if _dberr != nil {
		log.Println(_dberr)
	}
}

func GetDB() *gorm.DB {
	return _db
}
