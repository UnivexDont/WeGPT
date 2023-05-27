package main

import (
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/recover"
	jwtware "github.com/gofiber/jwt/v3"
	"univex.com/wegpt/controllers"
	"univex.com/wegpt/wegpt"
)

func WebLaunch() {
	app := fiber.New()
	app.Use(recover.New())
	app.Use(jwtware.New(jwtware.Config{
		Filter: func(c *fiber.Ctx) bool {
			filterPaths := []string{"/user/logout", "/user/generate/invite", "/user/invite/code"}

			filter := true
			for _, _path := range filterPaths {
				if strings.Contains(c.Path(), _path) {
					filter = false
					break
				}
			}
			return filter
		},
		SigningKey:   []byte(wegpt.PrivateSigningKey),
		ErrorHandler: wegpt.ErrorAuthorization,
	}))

	app.Use(jwtware.New(jwtware.Config{
		Filter: func(c *fiber.Ctx) bool {
			filterPaths := []string{"/user/logout", "/user/login", "/user/generate/invite",
				"/user/invite/code", "/user/verifycode/"}
			filter := true
			for _, _path := range filterPaths {
				if strings.Contains(c.Path(), _path) {
					filter = false
					break
				}
			}
			return filter
		},
		TokenLookup:  "header:SecretKey",
		ContextKey:   "secret",
		AuthScheme:   "Buller",
		SigningKey:   []byte(wegpt.PrivateSigningKey),
		ErrorHandler: wegpt.ErrorSecretKey,
	}))

	app.Get("/sys/time", wegpt.ServerTime)

	user := app.Group("/user")
	user.Post("/login", controllers.Login)
	user.Post("/logout", controllers.Logout)
	user.Get("/generate/invite", controllers.GenerateInviteCode)
	user.Get("/invite/code", controllers.InviteCode)
	user.Get("/verifycode/:email", controllers.EmailCode)

	app.Listen(":3555")
}
