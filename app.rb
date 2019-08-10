require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Привет, гость'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do
  erb :login_form
end

get '/admin' do
  erb :admin
end

post '/admin' do
  @username = params[:username]
  @password = params[:password]

  if @username == 'admin' && @password == 'admin'
    @users_file = File.open('./public/users.txt', 'r')
    erb :user_list
  # else
  #   erb :index
  end
end

get '/book' do # visit
  erb :book
end

post '/book' do
  @user_name = params[:user_name]
  @phone = params[:phone]
  @date_time = params[:date_time]
  @hair_dresser = params[:hair_dresser]
  @color = params[:color]

  f = File.open('./public/users.txt', 'a')
  f.write("User: #{@user_name}, Phone: #{@phone}, Date and Time: #{@date_time}, HairDresser: #{@hair_dresser} \n")
  f.close

  erb "Уважаемый #{@user_name}, Вы зарегистрировались на #{@date_time} к мастеру: #{@hair_dresser}. Вы выбрали #{@color} цвет. Спасибо"
end

post '/login/attempt' do
  if params[:username] == 'ilja' && params[:password] == '123456'
    session[:identity] = "Привет, #{params[:username]}"
    where_user_came_from = session[:previous_url] || '/'
    redirect to where_user_came_from
  else
    @error = 'Извините, Вы ввели не правильный логин или пароль! Попробуйте ещё раз.'
    halt erb(:login_form)
  end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

get '/about' do
  erb :about
end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  erb :contacts
  @email = params[:email]

  f = File.open('./public/contacts.txt', 'a')
  f.write("#{@email}\n")
  f.close

  halt erb "С Вашего электронного адреса: #{@email} отправленно письмо. Спасибо."
end