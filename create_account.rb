VALID_USERNAME_REGEX = /^.{3,100}$/
VALID_PASSWORD_REGEX = /^(?=.*[0-9])(?=.*[!@#$&*]).{8,}$/
VALID_TWITTER_HANDLE_REGEX = /^@?(\w){1,15}$/

#--------------------/create_account--------------------
#Here the user first authenticates their twitter handle.

get '/create_account' do 
    redirect '/my_account' unless not session[:logged_in]
    if session[:twitter_token] == nil
        session[:twitter_token] = (0...8).map { (65 + rand(26)).chr }.join
    end
    session[:twitter_handle_authenticated] = false
    erb :create_account
end

post '/create_account' do
    session[:twitter_handle] = format_twitter_handle params[:twitter_handle].strip.downcase
    if checkTwitterHandleTaken session[:twitter_handle]
        @error = "That twitter handle has already been taken"
        erb :create_account
    else
        @client.user_timeline(session[:twitter_handle]).take(10).each do |tweet|
            if tweet.text.include? session[:twitter_token]
                session[:twitter_handle_authenticated] = true
                redirect '/account_creation_form'
            end
        end
        if not session[:twitter_handle_authenticated]
            @error = "We couldn't find a tweet containing your token within your last 10 tweets."
            erb :create_account
        end
    end
end

#--------------------Twitter handle deauthentification--------------------
#Here the user can deauthenticate their twitter handle if they accidentally authenticated the wrong one

get '/deauthenticate_twitter_handle' do
    session[:twitter_token] = nil
    session[:twitter_handle_authenticated] = false
    session[:twitter_handle] = nil
    redirect '/'
end

#--------------------Account creation form--------------------
#Here the user can enter all the rest of their details after having authenticated their twitter handle

get '/account_creation_form' do
    redirect '/create_account' unless session[:twitter_handle_authenticated]
    #the twitter token has now been used & is removed from the session so if the user deauthenticates their twitter handle, they get a new token when they try to authenticate a new one.
    session[:twitter_token] = nil
    erb :account_creation_form
end

post '/account_creation_form' do
    username = format_username params[:username].strip
    password = params[:password].strip
    password_reentered = params[:password_reentered].strip

    if not username =~ VALID_USERNAME_REGEX
        @error_type = "username"
        @error = "Your username must be between 3 and 100 characters long."
        erb :account_creation_form
        
    elsif checkAccountExists username
        @error_type = "username"
        @error = "There already exists a user with that username."
        erb :account_creation_form
                
    elsif not password =~ VALID_PASSWORD_REGEX
        @error_type = "password"
        @error = "Your password must be at least 8 characters long, include a number and a special character (!, @, #, $, &, *)."
        erb :account_creation_form
        
    elsif password != password_reentered
        @error_type = "password"
        @error = "The passwords entered do not match."
        erb :account_creation_form
        
    else
        createAccount username, session[:twitter_handle], password
        log_in username
    end
end