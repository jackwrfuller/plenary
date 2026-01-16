package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"

	"mealplenary.jackwrfuller.au/internal/models"
)

func (app *app) render(w http.ResponseWriter, r *http.Request, status int, page string, data templateData) {
	ts, ok := app.templateCache[page]
	if !ok {
		err := fmt.Errorf("the template %s does not exist", page)
		app.serverError(w, r, err)
		return
	}

	buf := new(bytes.Buffer)
	err := ts.ExecuteTemplate(buf, "base", data)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	w.WriteHeader(status)
	buf.WriteTo(w)
}


func (app *app) home(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context() 
	recipes, err := app.queries.ListRecipesByUser(ctx, 1)
	if err != nil {
		app.serverError(w, r, err)
        return
    }

	data := app.newTemplateData(r)
	data.Recipes = recipes

	app.render(w, r, http.StatusOK, "home.tmpl", data)
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

	data := app.newTemplateData(r)
	data.Recipe = recipe

	app.render(w, r, http.StatusOK, "view.tmpl", data)
}

func (app *app) recipeCreate(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Create recipe form"))
}

func (app *app) recipeCreatePost(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Server", "Go")
	w.WriteHeader(http.StatusCreated)
	w.Write([]byte("Create recipe"))
}

