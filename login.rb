def log_in username
    session[:logged_in] = true
    session[:username] = username
    session[:user_type] = getUserType username
    session[:region] = getUserRegion username
    redirect '/my_account'
end

#--------------------/login--------------------

get '/login' do 
    redirect '/my_account' unless not session[:logged_in]
    erb :login
end

post '/login' do
    username = params[:username].strip.downcase
    password = params[:password].strip

    #If a user exists with that username...
    if checkAccountExists username

        #...and the password provided matches then the user is logged in.
        if checkAccountPassword username, password
            log_in username
        else
            #If the password hashes didn't match, the user's told the password they provided was incorrect.
            @error = "Incorrect password."
            erb :login
        end
    else
        #If the username wasn't found in the accounts db, the user's told we couldn't find an account with that username.
        @error = "We don't seem to have a user with that username."
        erb :login
    end
end

#--------------------/logout--------------------
#
get '/logout' do
    session.clear
    erb :logout
end