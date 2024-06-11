package main

import (
	"backend/utils"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/favicon"
	"github.com/gofiber/fiber/v2/middleware/logger"
	fiberrecover "github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/gofiber/fiber/v2/middleware/requestid"
	"os"
)

func main() {
	app := fiber.New()
	app.Use(requestid.New())
	app.Use(cors.New())
	app.Use(logger.New())

	app.Use(favicon.New())
	app.Use(fiberrecover.New())

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	app.Hooks().OnShutdown(func() error {
		log.Info("OnShutdown")
		return nil
	})

	go func() {
		err := app.Listen(":4001")
		if err != nil {
			log.Fatal(err)
		}
	}()

	log.Info("Running...")

	utils.WaitSignal(func(sig os.Signal) {
		log.Info("Gracefully shutting down...")
		log.Info("Waiting for all request to finish")
		err := app.Shutdown()
		if err != nil {
			log.Fatal(err)
		}
		log.Info("Running cleanup tasks...")
		log.Info("Server was successful shutdown.")
	})
}
