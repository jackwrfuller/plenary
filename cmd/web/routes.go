package main

import (
	"net/http"
)

func (app *app) routes() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", app.home)

	fileServer := http.FileServer(neuteredFileSystem{http.Dir(app.cfg.StaticDir)})
	mux.Handle("/static", http.NotFoundHandler())
	mux.Handle("/static/", http.StripPrefix("/static", fileServer))

	mux.HandleFunc("GET /recipe/view/{id}", app.recipeView)
	mux.HandleFunc("GET /recipe/create", app.recipeCreate)
	mux.HandleFunc("POST /recipe/create", app.recipeCreatePost)

	return mux
}
