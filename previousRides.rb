require 'erb'
require 'sinatra'
require 'sqlite3'

include ERB::Util

get '/previousride' do
  redirect '/' unless ["general_manager","accounts_manager"].include? session[:user_type]  
  unless params[:username].nil?
        #Shows all the previous rides for the custmore selected in the erb
        username = params[:username]
        if checkAccountExists username
            username = "\'#{username}\'"
            puts"#{username}"
            @results = $db.execute (%{select * from rides where username = #{username}})
        end
  end
    erb :previousride
end