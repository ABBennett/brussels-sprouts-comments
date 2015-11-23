require 'pg'

TITLES = ["Roasted Brussels Sprouts",
  "Fresh Brussels Sprouts Soup",
  "Brussels Sprouts with Toasted Breadcrumbs, Parmesan, and Lemon",
  "Cheesy Maple Roasted Brussels Sprouts and Broccoli with Dried Cherries",
  "Hot Cheesy Roasted Brussels Sprout Dip",
  "Pomegranate Roasted Brussels Sprouts with Red Grapes and Farro",
  "Roasted Brussels Sprout and Red Potato Salad",
  "Smoky Buttered Brussels Sprouts",
  "Sweet and Spicy Roasted Brussels Sprouts",
  "Smoky Buttered Brussels Sprouts",
  "Brussels Sprouts and Egg Salad with Hazelnuts"]

#WRITE CODE TO SEED YOUR DATABASE AND TABLES HERE

COMMENTS = [
  {"I love the taste" => 1},
  {"Weird consistency" => 2},
  {"Not sure what I think about this one" => 3},
  {"Smells like old socks" => 4},
  {"Made me really sleepy" => 4},
  {"Wasn't worth the time it took to cook" => 7},
  {"Yummy" => 9},
  {"Gross" => 9},
  {"Eh..." => 3},
  {"Could use more salt" => 5},
  {"Fishy" => 10},
  {"Drooling over this" => 11},
  {"Not even once" => 11},
  {"Yummmmm" => 5},
  {"burp" => 3},
  {"I need to unbuckle my belt" => 4},
  {"Where is the hot sauce" => 3},
  {"Can't look at that" => 8},
  {"Wanna vom" => 9}
]




def db_connection
  begin
    connection = PG.connect(dbname: "brussels_sprouts_recipes")
    yield(connection)
  ensure
    connection.close
  end
end
db_connection do |conn|
  conn.exec_params("DROP TABLE IF EXISTS comments;
  DROP TABLE IF EXISTS recipes;

  CREATE TABLE recipes (
    recipe_id SERIAL PRIMARY KEY,
    title VARCHAR(255)
  );

  CREATE TABLE comments (
    comment_id SERIAL PRIMARY KEY,
    comment VARCHAR(2000),
    recipe_id int REFERENCES recipes(recipe_id)
  );")
end

TITLES.each do |title|
  db_connection do |conn|
    conn.exec_params("INSERT INTO recipes (title)
      VALUES ($1);",
      ["#{title}"])
    end
end

COMMENTS.each do |hash|
  hash.each do |comment, recipe_id|
    db_connection do |conn|
      conn.exec_params("INSERT INTO comments (comment, recipe_id)
      VALUES ($1, $2);",
      ["#{comment}", "#{recipe_id}"])
    end
  end
end



# SELECT * FROM recipes

db_connection do |conn|
  @recipe_count = conn.exec_params("SELECT count(*) FROM recipes;")
end
@recipe_count.each do |count|
  puts "Recipe count: #{count["count"]}"
end


db_connection do |conn|
  @comment_count = conn.exec_params("SELECT count(*) FROM comments;")
end
@comment_count.each do |count|
  puts "Comment count: #{count["count"]}"
end

db_connection do |conn|
  @comments_by_recipe = conn.exec("SELECT count(recipe_id), recipe_id FROM comments GROUP BY recipe_id ORDER BY recipe_id")
end
puts

puts "Comment count for each recipe:"
@comments_by_recipe.each do |a|
  puts "Recipe #{a["recipe_id"]}: #{a["count"]}"
end
puts

db_connection do |conn|
  @comment_with_recipe_name = conn.exec("SELECT title, recipes.recipe_id, comment, comments.recipe_id
  FROM recipes, comments
  WHERE recipes.recipe_id = comments.recipe_id
  ORDER BY recipes.recipe_id
  ")
end

puts "Comment associated with each recipe:"
  @comment_with_recipe_name.each do |b|
    puts "#{b["title"].upcase}: #{b["comment"]}"
  end



db_connection do |conn|
  conn.exec_params("INSERT INTO recipes (title)
  VALUES ($1);", ['Brussels Sprouts with Goat Cheese'])

  conn.exec_params("INSERT INTO comments (comment, recipe_id)
  VALUES ($1, $2);", ['This is a comment', 12])

  conn.exec_params("INSERT INTO comments (comment, recipe_id)
  VALUES ($1, $2);", ['This is a different comment', 12])
end
