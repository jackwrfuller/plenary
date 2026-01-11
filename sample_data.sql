USE lagoon;

-- Insert a sample user
-- Password is "password123" hashed with bcrypt
INSERT INTO users (name, email, hashed_password, created) VALUES
('John Doe', 'john@example.com', '$2a$10$rQ3qKx7VFzd5o5Z5Z5Z5ZeO5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z', NOW());

SET @user_id = LAST_INSERT_ID();

-- Create user profile
INSERT INTO user_profile (user_id, meal_prep_rotation_size) VALUES
(@user_id, 3);

-- Insert ingredients
INSERT INTO ingredients (name, category, default_unit) VALUES
('Chicken Breast', 'meat', 'g'),
('Rice', 'pantry', 'g'),
('Broccoli', 'produce', 'g'),
('Olive Oil', 'pantry', 'ml'),
('Garlic', 'produce', 'cloves'),
('Onion', 'produce', 'units'),
('Tomatoes', 'produce', 'g'),
('Pasta', 'pantry', 'g'),
('Cheese', 'dairy', 'g'),
('Milk', 'dairy', 'ml'),
('Eggs', 'dairy', 'units'),
('Bread', 'bakery', 'loaf'),
('Butter', 'dairy', 'g'),
('Bell Peppers', 'produce', 'units'),
('Ground Beef', 'meat', 'g'),
('Soy Sauce', 'pantry', 'ml'),
('Ginger', 'produce', 'g'),
('Carrots', 'produce', 'g'),
('Potatoes', 'produce', 'g'),
('Salmon', 'meat', 'g');

-- Insert recipes
INSERT INTO recipes (user_id, name, serves, can_meal_prep, notes) VALUES
(@user_id, 'Chicken Stir Fry', 4, TRUE, 'Great for meal prep, keeps well in the fridge'),
(@user_id, 'Spaghetti Bolognese', 6, TRUE, 'Can freeze portions'),
(@user_id, 'Grilled Salmon with Vegetables', 2, FALSE, 'Best eaten fresh'),
(@user_id, 'Chicken and Rice Bowl', 4, TRUE, 'Perfect lunch meal prep'),
(@user_id, 'Vegetable Omelette', 2, FALSE, 'Quick breakfast option');

-- Get recipe IDs
SET @recipe1 = (SELECT id FROM recipes WHERE name = 'Chicken Stir Fry' AND user_id = @user_id);
SET @recipe2 = (SELECT id FROM recipes WHERE name = 'Spaghetti Bolognese' AND user_id = @user_id);
SET @recipe3 = (SELECT id FROM recipes WHERE name = 'Grilled Salmon with Vegetables' AND user_id = @user_id);
SET @recipe4 = (SELECT id FROM recipes WHERE name = 'Chicken and Rice Bowl' AND user_id = @user_id);
SET @recipe5 = (SELECT id FROM recipes WHERE name = 'Vegetable Omelette' AND user_id = @user_id);

-- Add ingredients to Chicken Stir Fry
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit, notes) VALUES
(@recipe1, (SELECT id FROM ingredients WHERE name = 'Chicken Breast'), 600, 'g', 'diced'),
(@recipe1, (SELECT id FROM ingredients WHERE name = 'Rice'), 400, 'g', 'uncooked'),
(@recipe1, (SELECT id FROM ingredients WHERE name = 'Broccoli'), 300, 'g', 'florets'),
(@recipe1, (SELECT id FROM ingredients WHERE name = 'Bell Peppers'), 2, 'units', 'sliced'),
(@recipe1, (SELECT id FROM ingredients WHERE name = 'Soy Sauce'), 60, 'ml', NULL),
(@recipe1, (SELECT id FROM ingredients WHERE name = 'Garlic'), 3, 'cloves', 'minced'),
(@recipe1, (SELECT id FROM ingredients WHERE name = 'Ginger'), 20, 'g', 'minced');

-- Add ingredients to Spaghetti Bolognese
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit, notes) VALUES
(@recipe2, (SELECT id FROM ingredients WHERE name = 'Ground Beef'), 800, 'g', NULL),
(@recipe2, (SELECT id FROM ingredients WHERE name = 'Pasta'), 500, 'g', NULL),
(@recipe2, (SELECT id FROM ingredients WHERE name = 'Tomatoes'), 800, 'g', 'crushed'),
(@recipe2, (SELECT id FROM ingredients WHERE name = 'Onion'), 2, 'units', 'diced'),
(@recipe2, (SELECT id FROM ingredients WHERE name = 'Garlic'), 4, 'cloves', 'minced'),
(@recipe2, (SELECT id FROM ingredients WHERE name = 'Olive Oil'), 30, 'ml', NULL);

-- Add ingredients to Grilled Salmon
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit, notes) VALUES
(@recipe3, (SELECT id FROM ingredients WHERE name = 'Salmon'), 400, 'g', 'fillets'),
(@recipe3, (SELECT id FROM ingredients WHERE name = 'Broccoli'), 200, 'g', NULL),
(@recipe3, (SELECT id FROM ingredients WHERE name = 'Carrots'), 150, 'g', 'sliced'),
(@recipe3, (SELECT id FROM ingredients WHERE name = 'Olive Oil'), 20, 'ml', NULL),
(@recipe3, (SELECT id FROM ingredients WHERE name = 'Garlic'), 2, 'cloves', 'minced');

-- Add ingredients to Chicken and Rice Bowl
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit, notes) VALUES
(@recipe4, (SELECT id FROM ingredients WHERE name = 'Chicken Breast'), 500, 'g', NULL),
(@recipe4, (SELECT id FROM ingredients WHERE name = 'Rice'), 300, 'g', NULL),
(@recipe4, (SELECT id FROM ingredients WHERE name = 'Broccoli'), 200, 'g', NULL),
(@recipe4, (SELECT id FROM ingredients WHERE name = 'Carrots'), 100, 'g', NULL);

-- Add ingredients to Vegetable Omelette
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit, notes) VALUES
(@recipe5, (SELECT id FROM ingredients WHERE name = 'Eggs'), 6, 'units', NULL),
(@recipe5, (SELECT id FROM ingredients WHERE name = 'Bell Peppers'), 1, 'units', 'diced'),
(@recipe5, (SELECT id FROM ingredients WHERE name = 'Onion'), 1, 'units', 'diced'),
(@recipe5, (SELECT id FROM ingredients WHERE name = 'Cheese'), 50, 'g', 'grated'),
(@recipe5, (SELECT id FROM ingredients WHERE name = 'Butter'), 20, 'g', NULL);

-- Add regular recipes (recipes to have each week)
INSERT INTO profile_regular_recipes (user_id, recipe_id, frequency_per_week) VALUES
(@user_id, @recipe5, 2); -- Omelette twice a week

-- Add BAU items (recurring grocery items)
INSERT INTO profile_bau_items (user_id, ingredient_id, quantity, unit) VALUES
(@user_id, (SELECT id FROM ingredients WHERE name = 'Milk'), 2000, 'ml'),
(@user_id, (SELECT id FROM ingredients WHERE name = 'Eggs'), 12, 'units'),
(@user_id, (SELECT id FROM ingredients WHERE name = 'Bread'), 1, 'loaf'),
(@user_id, (SELECT id FROM ingredients WHERE name = 'Butter'), 250, 'g');

-- Add meal prep recipes to rotation pool
INSERT INTO profile_meal_prep_recipes (user_id, recipe_id, last_used_at) VALUES
(@user_id, @recipe1, NULL), -- Never used yet
(@user_id, @recipe2, NULL),
(@user_id, @recipe4, NULL);

-- Create a meal plan for this week
INSERT INTO meal_plans (user_id, week_start_date, week_end_date, status) VALUES
(@user_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'active');

SET @meal_plan_id = LAST_INSERT_ID();

-- Add recipes to the meal plan
INSERT INTO meal_plan_recipes (meal_plan_id, recipe_id, servings_multiplier) VALUES
(@meal_plan_id, @recipe1, 1.0), -- Chicken Stir Fry
(@meal_plan_id, @recipe3, 1.0), -- Salmon
(@meal_plan_id, @recipe5, 2.0); -- Omelette x2

-- Add some individual items to the meal plan
INSERT INTO meal_plan_items (meal_plan_id, ingredient_id, quantity, unit, notes) VALUES
(@meal_plan_id, (SELECT id FROM ingredients WHERE name = 'Potatoes'), 1000, 'g', 'For roasting'),
(@meal_plan_id, (SELECT id FROM ingredients WHERE name = 'Cheese'), 200, 'g', 'Snacking');

-- Create shopping list for the meal plan
INSERT INTO shopping_lists (meal_plan_id) VALUES
(@meal_plan_id);

SET @shopping_list_id = LAST_INSERT_ID();

-- Add items to shopping list (normally this would be generated from the meal plan)
INSERT INTO shopping_list_items (shopping_list_id, ingredient_id, quantity, unit, category) VALUES
(@shopping_list_id, (SELECT id FROM ingredients WHERE name = 'Chicken Breast'), 1100, 'g', 'meat'),
(@shopping_list_id, (SELECT id FROM ingredients WHERE name = 'Salmon'), 400, 'g', 'meat'),
(@shopping_list_id, (SELECT id FROM ingredients WHERE name = 'Rice'), 400, 'g', 'pantry'),
(@shopping_list_id, (SELECT id FROM ingredients WHERE name = 'Broccoli'), 500, 'g', 'produce'),
(@shopping_list_id, (SELECT id FROM ingredients WHERE name = 'Eggs'), 24, 'units', 'dairy'),
(@shopping_list_id, (SELECT id FROM ingredients WHERE name = 'Milk'), 2000, 'ml', 'dairy'),
(@shopping_list_id, (SELECT id FROM ingredients WHERE name = 'Bread'), 1, 'loaf', 'bakery'),
(@shopping_list_id, (SELECT id FROM ingredients WHERE name = 'Butter'), 270, 'g', 'dairy'),
(@shopping_list_id, (SELECT id FROM ingredients WHERE name = 'Cheese'), 250, 'g', 'dairy'),
(@shopping_list_id, (SELECT id FROM ingredients WHERE name = 'Potatoes'), 1000, 'g', 'produce');
