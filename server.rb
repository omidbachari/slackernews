require 'redis'
require 'sinatra'
require 'json'


def find_articles
  redis = get_connection
  serialized_articles = redis.lrange("slacker:articles", 0, -1)

  articles = []

  serialized_articles.each do |article|
    articles << JSON.parse(article, symbolize_names: true)
  end

  articles
end

def save_article(url, title, description)
  article = { url: url, title: title, description: description }

  redis = get_connection
  redis.rpush("slacker:articles", article.to_json)
end

def get_connection
  if ENV.has_key?("REDISCLOUD_URL")
    Redis.new(url: ENV["REDISCLOUD_URL"])
  else
    Redis.new
  end
end

# def news_method
#   news = []
#   CSV.foreach("articles.csv", headers: true, header_converters: :symbol) do |row|
#     news << row.to_hash
#   end
#   news
# end

########## Test Methods ############

def test_title(title)
  if title == ""
    false
  end
end

def test_url(url)
  if !url.include?("http://") && !url.include?("https://") && !url.include?("www.")
    false
  end
end

def test_description(description)
  if description.length < 20
    false
  end
end

####################################

get '/' do
  @news_method = news_method
  erb :index
end


get '/comment' do
  @errors
  erb :comment
end


post '/comment' do
  title = params["title"]
  url = params["url"]
  description = params["description"]

  @errors = []

  if test_title(title) == false
    @errors << "No title."
  end

  if test_url(url) == false
    @errors << "Invalid URL."
  end

  if test_description(description) == false
    @errors << "Description must be more than 20 characters."
  end


  if @errors.count >= 1
    erb :comment
  else
    File.open('articles.csv', 'a') do |file|
      file.puts ("#{title},#{url},#{description}")
    end
    redirect '/'
  end
end
