DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS recipes;

CREATE TABLE recipes (
  recipe_id SERIAL PRIMARY KEY,
  title VARCHAR(255)
);

CREATE TABLE comments (
  comment_id SERIAL PRIMARY KEY,
  comment VARCHAR(2000),
  recipe_id int REFERENCES recipes(recipe_id)
);
