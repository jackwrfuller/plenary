package main

import (
	"fmt"
	"encoding/json"
	"html/template"
	"net/http"
	"strconv"
)


func (app *app) home(w http.ResponseWriter, r *http.Request) {
	files := []string{
		"./ui/html/base.tmpl",
		"./ui/html/partials/nav.tmpl",
		"./ui/html/pages/home.tmpl",
	}
	ts, err := template.ParseFiles(files...)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	err = ts.ExecuteTemplate(w, "base", nil)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

}

func (app *app) recipeList(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context() 
	recipes, err := app.queries.ListRecipesByUser(ctx, 1)
	if err != nil {
		app.serverError(w, r, err)
        return
    }
	
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(recipes); err != nil {
		app.serverError(w, r, err)
        return
    }

}

func (app *app) recipeView(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.PathValue("id"))
	if err != nil || id < 1 {
		http.NotFound(w, r)
		return
	}

	fmt.Fprintf(w, "Display recipe with ID %d", id)
}

func (app *app) recipeCreate(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Create recipe form"))
}

func (app *app) recipeCreatePost(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Server", "Go")
	w.WriteHeader(http.StatusCreated)
	w.Write([]byte("Create recipe"))
}

