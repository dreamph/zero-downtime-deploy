package utils

import (
	"os"
	"os/signal"
	"syscall"
)

func WaitSignal(fn func(os.Signal)) {
	termChan := make(chan os.Signal, 1)
	signal.Notify(termChan, os.Interrupt, syscall.SIGTERM)

	sig := <-termChan

	fn(sig)
}
