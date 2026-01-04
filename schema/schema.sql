USE lagoon;

-- Users table
CREATE TABLE users (
    id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    hashed_password CHAR(60) NOT NULL,
    created DATETIME NOT NULL
);

ALTER TABLE users ADD CONSTRAINT users_uc_email UNIQUE (email);

-- Recipes table
CREATE TABLE recipes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    serves INT NOT NULL DEFAULT 1,
    can_meal_prep BOOLEAN NOT NULL DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_recipes_user_id ON recipes(user_id);
CREATE INDEX idx_recipes_can_meal_prep ON recipes(user_id, can_meal_prep);

-- Ingredients table
CREATE TABLE ingredients (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL UNIQUE,
    category VARCHAR(100),
    default_unit VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX idx_ingredients_name ON ingredients(name);
CREATE INDEX idx_ingredients_category ON ingredients(category);

-- Recipe ingredients junction table
CREATE TABLE recipe_ingredients (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    recipe_id BIGINT NOT NULL,
    ingredient_id BIGINT NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    notes VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE,
    UNIQUE KEY unique_recipe_ingredient (recipe_id, ingredient_id)
);

CREATE INDEX idx_recipe_ingredients_recipe_id ON recipe_ingredients(recipe_id);
CREATE INDEX idx_recipe_ingredients_ingredient_id ON recipe_ingredients(ingredient_id);

-- User profile
CREATE TABLE user_profile (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL UNIQUE,
    meal_prep_rotation_size INT DEFAULT 3,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Regular recipes (recipes to include weekly)
CREATE TABLE profile_regular_recipes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    recipe_id BIGINT NOT NULL,
    frequency_per_week INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_recipe (user_id, recipe_id)
);

CREATE INDEX idx_profile_regular_recipes_user_id ON profile_regular_recipes(user_id);

-- BAU items (recurring items)
CREATE TABLE profile_bau_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    ingredient_id BIGINT NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_bau_ingredient (user_id, ingredient_id)
);

CREATE INDEX idx_profile_bau_items_user_id ON profile_bau_items(user_id);

-- Meal prep recipe pool
CREATE TABLE profile_meal_prep_recipes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    recipe_id BIGINT NOT NULL,
    last_used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_meal_prep_recipe (user_id, recipe_id)
);

CREATE INDEX idx_profile_meal_prep_recipes_user_id ON profile_meal_prep_recipes(user_id);
CREATE INDEX idx_profile_meal_prep_recipes_last_used ON profile_meal_prep_recipes(user_id, last_used_at);

-- Meal plans
CREATE TABLE meal_plans (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    status ENUM('draft', 'active', 'completed', 'archived') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_week (user_id, week_start_date)
);

CREATE INDEX idx_meal_plans_user_id ON meal_plans(user_id);
CREATE INDEX idx_meal_plans_week_start ON meal_plans(user_id, week_start_date);
CREATE INDEX idx_meal_plans_status ON meal_plans(user_id, status);

-- Meal plan recipes
CREATE TABLE meal_plan_recipes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    meal_plan_id BIGINT NOT NULL,
    recipe_id BIGINT NOT NULL,
    servings_multiplier DECIMAL(5, 2) DEFAULT 1.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (meal_plan_id) REFERENCES meal_plans(id) ON DELETE CASCADE,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

CREATE INDEX idx_meal_plan_recipes_meal_plan_id ON meal_plan_recipes(meal_plan_id);

-- Meal plan individual items
CREATE TABLE meal_plan_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    meal_plan_id BIGINT NOT NULL,
    ingredient_id BIGINT NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    notes VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (meal_plan_id) REFERENCES meal_plans(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
);

CREATE INDEX idx_meal_plan_items_meal_plan_id ON meal_plan_items(meal_plan_id);

-- Shopping lists
CREATE TABLE shopping_lists (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    meal_plan_id BIGINT NOT NULL UNIQUE,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (meal_plan_id) REFERENCES meal_plans(id) ON DELETE CASCADE
);

-- Shopping list items
CREATE TABLE shopping_list_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    shopping_list_id BIGINT NOT NULL,
    ingredient_id BIGINT NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    checked BOOLEAN DEFAULT FALSE,
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shopping_list_id) REFERENCES shopping_lists(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
);

CREATE INDEX idx_shopping_list_items_list_id ON shopping_list_items(shopping_list_id);
CREATE INDEX idx_shopping_list_items_category ON shopping_list_items(shopping_list_id, category);
