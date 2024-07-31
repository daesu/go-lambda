//go:build aws_lambda
// +build aws_lambda

package cmd

import (
	http "service/http"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/awslabs/aws-lambda-go-api-proxy/httpadapter"
	"github.com/rs/zerolog/log"
)

func Start(server *http.Server) error {
	adapter := httpadapter.New(server.Handler)

	log.Info().Msg("Starting Lambda")
	lambda.Start(adapter.Proxy)
	return nil
}
