package http

import (
	"net/http"

	"github.com/urfave/negroni"
)

type Server struct {
	*http.Server
}

func Address() string {
	return ":8081"
}

func NewServer() (*Server, error) {
	mux := http.NewServeMux()

	handler := NewHandler("handler")

	mux.Handle("/ping", handler)
	router := negroni.New()
	router.UseHandler(mux)

	srv := &http.Server{
		Addr:    Address(),
		Handler: router,
	}

	return &Server{srv}, nil
}
