package wegpt

import (
	"fmt"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v4"
	"github.com/spf13/viper"
)

var (
	PrivateSigningKey = "wegpt-chat-ai-secret"
	AppKey            = "wegpt-chat-bot"
)

type Result struct {
	Status  int         `json:"status"`
	Code    string      `json:"code"`
	Data    interface{} `json:"data"`
	Message string      `json:"message"`
}

type SysTime struct {
	Time int64 `json:"time"`
}

type QuantAIConfig struct {
	Application ApplicationConfig `yaml:"application"`
	DataBase    DataBaseConfig    `yaml:"database"`
	SMSCode     SMSCodeConfig     `yaml:"smsCode"`
}

type ApplicationConfig struct {
	Name    string `yaml:"name"`
	Version string `yaml:"version"`
}

type DataBaseConfig struct {
	Name string `yaml:"name"`
	Host string `yaml:"host"`
	Port string `yaml:"port"`
	User string `yaml:"user"`
	Pass string `yaml:"pass"`
}

type SMSCodeConfig struct {
	SignName     string `yaml:"signName"`
	TemplateCode string `yaml:"templateCode"`
}

var _config QuantAIConfig

func init() {
	viper.AddConfigPath("./wegpt")
	viper.SetConfigName("config")
	// viper.SetConfigName("config")
	viper.SetConfigType("yaml")

	err := viper.ReadInConfig() // Find and read the config file
	if err != nil {             // Handle errors reading the config file
		panic(fmt.Errorf("fatal error config file: %w", err))
	}

	if err != nil { // Handle errors reading the config file
		panic(fmt.Errorf("fatal error config file: %w", err))
	}

	err = viper.Unmarshal(&_config)
	if err != nil {
		panic(err)
	}

}

func GetConfig() *QuantAIConfig {
	return &_config
}

func GetDataBaseConfig() *DataBaseConfig {
	return &_config.DataBase
}

func AuthSecretKey(c *fiber.Ctx) error {
	secret := c.Locals("secret").(*jwt.Token)
	claims := secret.Claims.(jwt.MapClaims)
	timeStamp := claims["time"].(float64)
	appKey := claims["appKey"].(string)
	if time.Now().Unix()-int64(timeStamp) >= 10 || appKey != AppKey {
		return &fiber.Error{Message: "Invalid SecretKey... "}
	}
	return nil
}

func UserIDFromToken(c *fiber.Ctx) uint {
	secret := c.Locals("user").(*jwt.Token)
	claims := secret.Claims.(jwt.MapClaims)
	user_id := claims["userId"].(float64)

	return uint(user_id)
}

func ErrorAuthorization(c *fiber.Ctx, err error) error {
	if err.Error() == "Missing or malformed JWT" {
		return c.Status(fiber.StatusBadRequest).
			JSON(Result{Status: fiber.StatusUnauthorized, Message: "Missing token..."})

	}
	return c.Status(fiber.StatusUnauthorized).
		JSON(Result{Status: fiber.StatusUnauthorized, Message: "Invalid or expired token..."})
}

func ErrorSecretKey(c *fiber.Ctx, err error) error {
	if err.Error() == "Missing or malformed JWT" {
		return c.Status(fiber.StatusUnauthorized).
			JSON(Result{Status: fiber.StatusUnauthorized, Message: "Missing SecretKey..."})
	}
	return c.Status(fiber.StatusUnauthorized).
		JSON(Result{Status: fiber.StatusUnauthorized, Message: "Invalid SecretKey..."})
}

func ServerTime(c *fiber.Ctx) error {
	return c.Status(fiber.StatusOK).
		JSON(Result{Status: fiber.StatusOK, Message: "", Data: SysTime{Time: time.Now().Unix()}})
}
