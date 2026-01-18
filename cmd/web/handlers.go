package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"database/sql"
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
	data := app.newTemplateData(r)

	app.render(w, r, http.StatusOK, "recipeCreate.tmpl", data)
}

func (app *app) recipeCreatePost(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	name          := r.PostForm.Get("name")
	notes         := r.PostForm.Get("notes")
	serves, err   := strconv.Atoi(r.PostForm.Get("serves"))
	if err != nil {
		serves = 0
	}
	prepable, err := strconv.ParseBool(r.PostForm.Get("can_meal_prep"))
	if err != nil {
		prepable = false
	}

	params := models.CreateRecipeParams{
		UserID: int32(1),
		Name: name,
		Notes: sql.NullString{
        	String: notes,
        	Valid:  notes != "",
    	},
		CanMealPrep: prepable,
		Serves: int32(serves),

	}	
	res, err := app.queries.CreateRecipe(ctx, params)
	if err != nil {
		app.serverError(w, r, err)
	}

	id, err := res.LastInsertId()
	if err != nil {
		app.serverError(w, r, err)
	}

	http.Redirect(w, r, fmt.Sprintf("/recipe/view/%d", id), http.StatusSeeOther)
}

