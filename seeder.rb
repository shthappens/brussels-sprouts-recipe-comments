require "pg"
require "csv"
require "pry"
require "faker"
system "psql brussels_sprouts_recipes < schema.sql"

TITLES = [
  "Roasted Brussels Sprouts",
  "Fresh Brussels Sprouts Soup",
  "Brussels Sprouts with Toasted Breadcrumbs, Parmesan, and Lemon",
  "Cheesy Maple Roasted Brussels Sprouts and Broccoli with Dried Cherries",
  "Hot Cheesy Roasted Brussels Sprout Dip",
  "Pomegranate Roasted Brussels Sprouts with Red Grapes and Farro",
  "Roasted Brussels Sprout and Red Potato Salad",
  "Smoky Buttered Brussels Sprouts",
  "Sweet and Spicy Roasted Brussels Sprouts",
  "Smoky Buttered Brussels Sprouts",
  "Brussels Sprouts and Egg Salad with Hazelnuts",
  "Brussels Sprouts with Goat Cheese"
]

# Write code to seed your database, here

def db_connection
  begin
    connection = PG.connect(dbname: "brussels_sprouts_recipes")
    yield(connection)
  ensure
    connection.close
  end
end

TITLES.each do |title|
  db_connection do |conn|
    result = conn.exec_params(
    "SELECT recipe_name FROM recipes WHERE recipe_name=$1",
    [title]
    )

    if result.to_a.empty?
      sql = "INSERT INTO recipes (recipe_name) VALUES ($1)"
      conn.exec_params(sql, [title])
    end
  end
end

@sentences = Faker::Hipster.sentences(30)

@sentences.each do |comment|
  db_connection do |conn|
    conn.exec_params("INSERT INTO comments (body, recipe_id) VALUES ($1, $2)", [comment, rand(1..10)])
  end
end

db_connection do |conn|
  conn.exec_params("INSERT INTO comments (body, recipe_id) VALUES ($1, $2)", [@sentences[1], 11])
  conn.exec_params("INSERT INTO comments (body, recipe_id) VALUES ($1, $2)", [@sentences[2], 11])
end

db_connection do |conn|
  recipe_count = conn.exec_params("SELECT * FROM recipes").to_a
  comment_count = conn.exec_params("SELECT * FROM comments").to_a
  ind_comment = conn.exec_params("SELECT body FROM comments WHERE recipe_id = 11").to_a

  comments_array = []
  ind_comment.each do |comments|
    comments.each do |body, comment|
      comments_array << comment
    end
  end

  puts "There are #{recipe_count.length} recipes."
  puts "There are #{comment_count.length} comments."
  puts "#{TITLES[0]} has #{ind_comment.length} comments."
  puts "The comments for '#{TITLES[11]}' are: '#{comments_array[0]}' and '#{comments_array[1]}'."
end
