package main

import (
	"encoding/json"
	"html/template"
	"net/http"
	"strconv"

	"mealplenary.jackwrfuller.au/internal/models"
)


func (app *app) home(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context() 
	recipes, err := app.queries.ListRecipesByUser(ctx, 1)
	if err != nil {
		app.serverError(w, r, err)
        return
    }

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

	data := templateData{
		Recipes: recipes,
	}
	err = ts.ExecuteTemplate(w, "base", data)
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
	ctx := r.Context()

	id, err := strconv.Atoi(r.PathValue("id"))
	if err != nil || id < 1 {
		http.NotFound(w, r)
		return
	}

	params := models.GetRecipeParams{int64(id), 1}
	recipe, err := app.queries.GetRecipe(ctx, params)
	if err != nil {
		app.serverError(w, r, err)
        return
	}

	files := []string{
		"./ui/html/base.tmpl",
		"./ui/html/partials/nav.tmpl",
		"./ui/html/pages/view.tmpl",
	}
	ts, err := template.ParseFiles(files...)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	data := templateData{
		Recipe: recipe,
	}

	err = ts.ExecuteTemplate(w, "base", data)
	if err != nil {
		app.serverError(w, r, err)
	}
}

func (app *app) recipeCreate(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Create recipe form"))
}

func (app *app) recipeCreatePost(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Server", "Go")
	w.WriteHeader(http.StatusCreated)
	w.Write([]byte("Create recipe"))
}

