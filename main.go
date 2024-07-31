package main

import (
	"service/cmd"
	"service/http"

	"github.com/rs/zerolog/log"
)

func main() {
	// initialize http server
	server, err := http.NewServer()
	if err != nil {
		log.Fatal().Err(err).Msg("couldn't initialize server")
	}

	if err := cmd.Start(server); err != nil {
		log.Fatal().Err(err).Msg("couldn't start server")
	}
}
