package main

import (
	"net/http"

	"github.com/justinas/alice"
)

func (app *app) routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", app.home)

	fileServer := http.FileServer(neuteredFileSystem{http.Dir(app.cfg.StaticDir)})
	mux.Handle("/static", http.NotFoundHandler())
	mux.Handle("/static/", http.StripPrefix("/static", fileServer))

	mux.HandleFunc("GET /recipe/view/{id}", app.recipeView)
	mux.HandleFunc("GET /recipe/create", app.recipeCreate)
	mux.HandleFunc("POST /recipe/create", app.recipeCreatePost)
	mux.HandleFunc("GET /recipe/list", app.recipeList)

	standardMiddleware := alice.New(app.recoverPanic, app.logRequest, commonHeaders)

	return standardMiddleware.Then(mux)
}
