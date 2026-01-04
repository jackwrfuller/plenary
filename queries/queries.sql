-- name: CreateUser :execresult
INSERT INTO users (name, email, hashed_password, created)
VALUES (?, ?, ?, ?);

-- name: GetUserByEmail :one
SELECT * FROM users
WHERE email = ?;

-- name: GetUserByID :one
SELECT * FROM users
WHERE id = ?;

-- ============================================================================
-- RECIPES
-- ============================================================================

-- name: CreateRecipe :execresult
INSERT INTO recipes (user_id, name, serves, can_meal_prep, notes)
VALUES (?, ?, ?, ?, ?);

-- name: GetRecipe :one
SELECT * FROM recipes
WHERE id = ? AND user_id = ?;

-- name: ListRecipesByUser :many
SELECT * FROM recipes
WHERE user_id = ?
ORDER BY name;

-- name: ListMealPrepRecipes :many
SELECT * FROM recipes
WHERE user_id = ? AND can_meal_prep = TRUE
ORDER BY name;

-- name: UpdateRecipe :exec
UPDATE recipes
SET name = ?, serves = ?, can_meal_prep = ?, notes = ?
WHERE id = ? AND user_id = ?;

-- name: DeleteRecipe :exec
DELETE FROM recipes
WHERE id = ? AND user_id = ?;

-- ============================================================================
-- INGREDIENTS
-- ============================================================================

-- name: CreateIngredient :execresult
INSERT INTO ingredients (name, category, default_unit)
VALUES (?, ?, ?);

-- name: GetIngredient :one
SELECT * FROM ingredients
WHERE id = ?;

-- name: GetIngredientByName :one
SELECT * FROM ingredients
WHERE name = ?;

-- name: ListIngredients :many
SELECT * FROM ingredients
ORDER BY name;

-- name: ListIngredientsByCategory :many
SELECT * FROM ingredients
WHERE category = ?
ORDER BY name;

-- ============================================================================
-- RECIPE INGREDIENTS
-- ============================================================================

-- name: AddIngredientToRecipe :execresult
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit, notes)
VALUES (?, ?, ?, ?, ?);

-- name: GetRecipeIngredients :many
SELECT ri.*, i.name as ingredient_name, i.category
FROM recipe_ingredients ri
JOIN ingredients i ON ri.ingredient_id = i.id
WHERE ri.recipe_id = ?;

-- name: DeleteRecipeIngredient :exec
DELETE FROM recipe_ingredients
WHERE recipe_id = ? AND ingredient_id = ?;

-- name: UpdateRecipeIngredient :exec
UPDATE recipe_ingredients
SET quantity = ?, unit = ?, notes = ?
WHERE recipe_id = ? AND ingredient_id = ?;

-- ============================================================================
-- USER PROFILE
-- ============================================================================

-- name: CreateUserProfile :execresult
INSERT INTO user_profile (user_id, meal_prep_rotation_size)
VALUES (?, ?);

-- name: GetUserProfile :one
SELECT * FROM user_profile
WHERE user_id = ?;

-- name: UpdateUserProfile :exec
UPDATE user_profile
SET meal_prep_rotation_size = ?
WHERE user_id = ?;

-- ============================================================================
-- PROFILE REGULAR RECIPES
-- ============================================================================

-- name: AddRegularRecipe :execresult
INSERT INTO profile_regular_recipes (user_id, recipe_id, frequency_per_week)
VALUES (?, ?, ?);

-- name: ListRegularRecipes :many
SELECT prr.*, r.name as recipe_name, r.serves, r.can_meal_prep
FROM profile_regular_recipes prr
JOIN recipes r ON prr.recipe_id = r.id
WHERE prr.user_id = ?;

-- name: RemoveRegularRecipe :exec
DELETE FROM profile_regular_recipes
WHERE user_id = ? AND recipe_id = ?;

-- name: UpdateRegularRecipeFrequency :exec
UPDATE profile_regular_recipes
SET frequency_per_week = ?
WHERE user_id = ? AND recipe_id = ?;

-- ============================================================================
-- PROFILE BAU ITEMS
-- ============================================================================

-- name: AddBAUItem :execresult
INSERT INTO profile_bau_items (user_id, ingredient_id, quantity, unit)
VALUES (?, ?, ?, ?);

-- name: ListBAUItems :many
SELECT pbi.*, i.name as ingredient_name, i.category
FROM profile_bau_items pbi
JOIN ingredients i ON pbi.ingredient_id = i.id
WHERE pbi.user_id = ?;

-- name: RemoveBAUItem :exec
DELETE FROM profile_bau_items
WHERE user_id = ? AND ingredient_id = ?;

-- name: UpdateBAUItem :exec
UPDATE profile_bau_items
SET quantity = ?, unit = ?
WHERE user_id = ? AND ingredient_id = ?;

-- ============================================================================
-- PROFILE MEAL PREP RECIPES
-- ============================================================================

-- name: AddMealPrepRecipe :execresult
INSERT INTO profile_meal_prep_recipes (user_id, recipe_id)
VALUES (?, ?);

-- name: ListMealPrepRecipesPool :many
SELECT pmr.*, r.name as recipe_name, r.serves
FROM profile_meal_prep_recipes pmr
JOIN recipes r ON pmr.recipe_id = r.id
WHERE pmr.user_id = ?
ORDER BY ISNULL(pmr.last_used_at), pmr.last_used_at ASC;

-- name: RemoveMealPrepRecipe :exec
DELETE FROM profile_meal_prep_recipes
WHERE user_id = ? AND recipe_id = ?;

-- name: UpdateMealPrepRecipeLastUsed :exec
UPDATE profile_meal_prep_recipes
SET last_used_at = ?
WHERE user_id = ? AND recipe_id = ?;

-- ============================================================================
-- MEAL PLANS
-- ============================================================================

-- name: CreateMealPlan :execresult
INSERT INTO meal_plans (user_id, week_start_date, week_end_date, status)
VALUES (?, ?, ?, ?);

-- name: GetMealPlan :one
SELECT * FROM meal_plans
WHERE id = ? AND user_id = ?;

-- name: GetMealPlanByWeek :one
SELECT * FROM meal_plans
WHERE user_id = ? AND week_start_date = ?;

-- name: ListMealPlans :many
SELECT * FROM meal_plans
WHERE user_id = ?
ORDER BY week_start_date DESC;

-- name: UpdateMealPlanStatus :exec
UPDATE meal_plans
SET status = ?
WHERE id = ? AND user_id = ?;

-- name: DeleteMealPlan :exec
DELETE FROM meal_plans
WHERE id = ? AND user_id = ?;

-- ============================================================================
-- MEAL PLAN RECIPES
-- ============================================================================

-- name: AddRecipeToMealPlan :execresult
INSERT INTO meal_plan_recipes (meal_plan_id, recipe_id, servings_multiplier)
VALUES (?, ?, ?);

-- name: GetMealPlanRecipes :many
SELECT mpr.*, r.name as recipe_name, r.serves, r.can_meal_prep
FROM meal_plan_recipes mpr
JOIN recipes r ON mpr.recipe_id = r.id
WHERE mpr.meal_plan_id = ?;

-- name: RemoveRecipeFromMealPlan :exec
DELETE FROM meal_plan_recipes
WHERE meal_plan_id = ? AND recipe_id = ?;

-- name: UpdateMealPlanRecipeServings :exec
UPDATE meal_plan_recipes
SET servings_multiplier = ?
WHERE meal_plan_id = ? AND recipe_id = ?;

-- ============================================================================
-- MEAL PLAN ITEMS
-- ============================================================================

-- name: AddItemToMealPlan :execresult
INSERT INTO meal_plan_items (meal_plan_id, ingredient_id, quantity, unit, notes)
VALUES (?, ?, ?, ?, ?);

-- name: GetMealPlanItems :many
SELECT mpi.*, i.name as ingredient_name, i.category
FROM meal_plan_items mpi
JOIN ingredients i ON mpi.ingredient_id = i.id
WHERE mpi.meal_plan_id = ?;

-- name: RemoveItemFromMealPlan :exec
DELETE FROM meal_plan_items
WHERE id = ? AND meal_plan_id = ?;

-- name: UpdateMealPlanItem :exec
UPDATE meal_plan_items
SET quantity = ?, unit = ?, notes = ?
WHERE id = ? AND meal_plan_id = ?;

-- ============================================================================
-- SHOPPING LISTS
-- ============================================================================

-- name: CreateShoppingList :execresult
INSERT INTO shopping_lists (meal_plan_id)
VALUES (?);

-- name: GetShoppingList :one
SELECT * FROM shopping_lists
WHERE meal_plan_id = ?;

-- name: DeleteShoppingList :exec
DELETE FROM shopping_lists
WHERE meal_plan_id = ?;

-- ============================================================================
-- SHOPPING LIST ITEMS
-- ============================================================================

-- name: AddItemToShoppingList :execresult
INSERT INTO shopping_list_items (shopping_list_id, ingredient_id, quantity, unit, category)
VALUES (?, ?, ?, ?, ?);

-- name: GetShoppingListItems :many
SELECT sli.*, i.name as ingredient_name
FROM shopping_list_items sli
JOIN ingredients i ON sli.ingredient_id = i.id
WHERE sli.shopping_list_id = ?
ORDER BY sli.category, i.name;

-- name: ToggleShoppingListItem :exec
UPDATE shopping_list_items
SET checked = ?
WHERE id = ? AND shopping_list_id = ?;

-- name: ClearShoppingList :exec
DELETE FROM shopping_list_items
WHERE shopping_list_id = ?;
