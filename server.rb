require 'sinatra'
require 'CSV'
require 'pry'
 
def news_method
  news = []
  CSV.foreach("articles.csv", headers: true, header_converters: :symbol) do |row|
    news << row.to_hash
  end
  news
end
 
 
get '/' do
  @news_method = news_method
  erb :index
end
 
 
get '/comment' do
  erb :comment
end
 
 
post '/comment' do
  title = params["title"]
  url = params["url"]
  description = params["description"]
 
  File.open('articles.csv', 'a') do |file|
    file.puts ("#{title},#{url},#{description}")
  end
  redirect '/'
  erb :comment
end
