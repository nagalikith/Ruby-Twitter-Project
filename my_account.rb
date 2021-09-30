get '/my_account' do
    redirect '/' unless session[:logged_in]
    @user_details = getAccountDetails session[:username]
    if session[:user_type] == "customer" then
        #If the user is a customer it shows the previous rides
        @user_offers = getAccountOffers session[:username]
        username = session[:username]
        username = "\'#{username}\'"
        @results = $db.execute %{SELECT * from rides where username = #{username}}
    end    
    
    erb :my_account
end
    
post '/my_account' do
    redirect '/' unless session[:logged_in]
    
    new_twitter_handle = params[:twitter_handle]
    new_home_address = params[:home_address]
    
    @message = "Updated your information."
    #Allows the customer to change the home address and twitter handle
    if checkTwitterHandleTaken new_twitter_handle and getTwitterHandle(session[:username]) != new_twitter_handle then
        @message = "Someone has already taken that twitter handle."
    else
        updateTwitterHandle session[:username], new_twitter_handle
        updateHomeAddress session[:username], new_home_address
    end

    @user_details = getAccountDetails session[:username]
    
    if session[:user_type] == "customer" then
        #Gets the Offers for the user 
        @user_offers = getAccountOffers session[:username]
    end
    
    erb :my_account
end