get '/marketmanager' do
    redirect '/' unless ["general_manager","marketting_manager"].include? session[:user_type]
    @rows = displaytweets()
    erb :marketmanager
end

get '/marketmanager_create' do 
    redirect '/' unless ["general_manager","marketting_manager"].include? session[:user_type]    
    unless params[:date].nil? || params[:date] == ''
        date = params[:date]
        puts "Retweet to win a free ride Competetion ends on #{date}.PLease remember that the winner must have a linked Fake Twaxi account"
        # Starts the Competetion by sending out a tweet
        startCompetition(date)
    end
    erb :marketmanager_create
end

get '/marketmanager_end' do 
    redirect '/' unless ["general_manager","marketting_manager"].include? session[:user_type]    
    puts "#{params[:input]}"
    unless params[:input].nil?
        tweet_row = params[:input]
        tweet_id = tweet_row
        endCompetition(tweet_id)
        puts"Work done"
    end
    erb :marketmanager_end
end

def startCompetition(date)
    message = "Retweet to win a free ride Competetion ends on #{date}" 
    #Sends the Tweet out.
    @client.update(message)
    tweets = @client.user_timeline('ise19team12')
    most_recent = tweets.take(3)
    most_recent.each do |tweet|
        #Checks for tweet that was sent out
        if tweet.text == message then
            # Inserts into the database
            insertToDatabase(tweet.id,date,tweet.text)
        end
    end
end 
            
def endCompetition(tweet_id)
    winners_list = []
    # Gets the 100 most recent retweeter's Id 
    retweets = @client.retweeters_ids(tweet_id, options = {'count' => 100 } )
    retweets.each do |item|
       winner_tweet = @client.user(item)
       screen_name  = winner_tweet.screen_name
        puts "#{screen_name}"
       # Checks if the retweeter is a FakeTwaxi user.
       if checkTwitterHandleTakenF screen_name then
           # Makes a list of the retweeter who have a account
           winners_list.push(screen_name)
       end
    end
    puts "winners list: #{winners_list}"
    if winners_list.length == 0 then
        puts "No winner to Select"
    else
        # Selects a random winner from the users
        winner = rand(0...winners_list.length)
        # Sends a tweet out to the winner 
        @client.update("@#{winners_list[winner]}, Congratulations the prize has been added to your Fake Twaxi account")
        #Adds Offer to table
        addOffer(winners_list[winner])
        # Deletes the competition from the database
        deletetweets(tweet_id)
    end
    
end

def displaytweets()
    begin
        # Gets all the rows to display on the Dashboard
        region = getUserRegion session[:username]
        puts"#{region}"
        region = "\'#{region}\'"
        rows = $db.execute2 "SELECT * FROM competition_tweets WHERE region = #{region} ORDER BY end_date ASC"
        rows.delete_at(0)
        return rows
    end
end

def deletetweets(tweet_id)
    begin
        rows = $db.execute2 "DELETE FROM competition_tweets WHERE tweet_id = #{tweet_id};"
        return rows        
    rescue SQLite3::Exception => e 
        puts "Exception occurred"
        puts e
    end
end    
    
def insertToDatabase(tweet_id,date,message)
    begin
        #Moved SQL query to competition_tweets_db_utilities.rb
        region = getUserRegion session[:username]
        insertNewCompetitionTweet tweet_id, date, message, region
    rescue SQLite3::Exception => e 
        puts "Exception occurred"
        puts e
    end
end

def checkTwitterHandleTakenF twitter_handle
    #Check if the retweeter is a customer
    twitter_handles = $db.execute(%{SELECT twitter_handle FROM users})
    return twitter_handles.include? ["@"+twitter_handle]
end

def addOffer twitter_handle
    #Converts Twitter Handle to Username and adds to the offer page
    username = getUserByTwitterHandle ["@"+twitter_handle]
    $db.execute(%{INSERT INTO offers VALUES(?, ?)}, 
        username,"Free Ride From Retweet")
end
        
