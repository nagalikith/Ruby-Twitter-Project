get '/twittermanager' do
  redirect '/' unless ["general_manager","twitter_manager"].include? session[:user_type]    
  
  session[:conversation] = [['Unknown', 'Please select a conversation on the left', '', '', 0]]
  session[:conversationTwitterHandle] = nil
  session[:conversationBranch] = nil
  session[:home_address] = "None"
  
  $listOfConversations = conversationList(true, false)
  $conversation = session[:conversation]
  
  erb :twittermanager
end

post '/twittermanager' do
  redirect '/' unless ["general_manager","twitter_manager"].include? session[:user_type]  
    
  session[:home_address] = "None"
  
  $listOfConversations = conversationList(params[:tweet_active], params[:tweet_handled])
  $conversation = session[:conversation]
  
  # Get which type of button has been clicked
  method = params[:method]
  
  # DEBUG : Show the selected method
  puts "<------- POST TWITTER MANAGER ------->"
  puts "params: #{params}"
  puts "params[:tweets_active]: #{params[:tweets_active]}"
  puts "params[:tweets_handled]: #{params[:tweets_handled]}"
  puts "params[:method]: #{params[:method]}"
  puts "params[:conversationID]: #{params[:conversationID]}"
  puts "params[:rideTwitterHandle]: #{params[:rideTwitterHandle]}"
  
  # Perform the appropriate action
  if method == "conversationList"
    puts "  <--- Method selected: conversationList --->"
    # Get filters
    if params[:tweets_active] == "on"
      tweetsActive = true
    else
      tweetsActive = false
    end
    if params[:tweets_handled] == "on"
      tweetsHandled = true
    else
      tweetsHandled = false
    end
    
    # Generate list of conversations
    $listOfConversations = conversationList(tweetsActive, tweetsHandled)
  elsif method == "showConversation"
    puts "  <--- Method selected: showConversation --->"
    # Get tweetID of selected conversation
    tweetID = $listOfConversations[params[:conversationID].to_i]
    
    $conversation = showConversation(params[:conversationID].to_i)
    
    session[:conversation] = $conversation
    session[:conversationTwitterHandle] = $conversation[0][2]
  elsif method == "sendReply"
    puts "  <--- Method selected: sendReply --->"
    message = params[:message]
    inReplyTo = params[:inReplyTo]
    rootTweet = params[:rootTweetID]
    
    puts "message: /\"#{message}/\""
    puts "inReplyTo: /\"#{inReplyTo}/\""
    puts "rootTweet: /\"#{rootTweet}/\""
        
    # If the handle being replied to is not yourself (ise19team12),
    # then add a mention of them in the message so that the reply is sent
    inReplyToHandle = @client.status(inReplyTo).user.screen_name
    if inReplyToHandle != "ise19team12"
      message = "@" + inReplyToHandle + " " + message
    end
    
    puts "message is now: /\"#{message}/\""
    
    sendReply(message, inReplyTo)
    
    $conversation = showConversation(rootTweet)
  elsif method == "createRide"
    puts "  <--- Method selected: createRide --->"    
    # Get params (origin, destination, twitterHandle)
    rideOrigin = params[:rideOrigin]
    rideDestination = params[:rideDestination]
    rideTwitterHandle = session[:conversationTwitterHandle]
    rideTwitterHandle = rideTwitterHandle[1..rideTwitterHandle.length]
    
    puts "rideOrigin: #{rideOrigin}"
    puts "rideDestination: #{rideDestination}"
    puts "rideTwitterHandle: #{rideTwitterHandle}"
    
    createRide(rideOrigin, rideDestination, rideTwitterHandle)
  elsif method == "updateBranch"
    # Take param of new branch
    newBranch = params[:branch].downcase
    puts "newBranch: #{newBranch}"
    
    # Get root ID
    rootTweetID = session[:conversation][0][3]
    
    # Update root ID
    $db.execute(%{UPDATE customer_tweets SET branch = '#{newBranch}' WHERE tweet_id = '#{rootTweetID}'})
  end
  
  erb :twittermanager
end

# Method : conversationList
def conversationList(active, handled)
  # DEBUG : Display current status
  puts "    <--- Executing conversationList()... --->"
  
  # Search twitter for new tweets @ise19team12 and add them to the database
  # Add them to the database
  updateDatabase()
  
  # Generate an array of tweets that will be used in the view
  listOfConversations = getListOfConversations(active, handled) 
  
  return listOfConversations
end

def getListOfConversations(filterActive, filterHandled)
  # DEBUG : Display current status
  puts "    <--- Executing getListOfConversations()... --->"
  
  # Get a list of tweets that are in the database, are a root tweet and are either 'Handled' or 'Active'
  # TO DO : Move SQL query to other file
  #listOfTweetsInDB = getTweets()
  if filterActive && filterHandled
    listOfTweetsInDB = $db.execute(%{SELECT * FROM customer_tweets WHERE (status = 'Handled' OR status = 'Active') AND in_reply_to = '0' AND (branch = \'#{session[:region]}\' OR branch = 'unknown')})
  elsif filterActive
    listOfTweetsInDB = $db.execute(%{SELECT * FROM customer_tweets WHERE (status = 'Active') AND in_reply_to = '0' AND (branch = \'#{session[:region].downcase}\' OR branch = 'unknown')})
  elsif filterHandled
    listOfTweetsInDB = $db.execute(%{SELECT * FROM customer_tweets WHERE (status = 'Handled') AND in_reply_to = '0' AND (branch = \'#{session[:region]}\' OR branch = 'unknown')})
  else
    listOfTweetsInDB = [[0, 'Error', 'Error', 'Error', 0, 'Error']]
  end
    
  # For every tweet in the database, 
  # add the status, text, user handle and username to the list displayTweets
  displayTweets = []
  i = 0
  listOfTweetsInDB.each do |t|
    begin
      if t[1] == 'Error'
        displayTweets[i] = ['errortweet', 'Please select filters above', 'Error', 0]
      else
        # Get data about the tweet
        tweet = @client.status(t[0])
        tweetStatus = (t[1] + 'tweet').downcase
        tweetText = tweet.text
        tweetHandle = t[2]
        tweetID = t[0]
      
        # Add the tweet to the list
        displayTweets[i] = [tweetStatus, tweetText, tweetHandle, tweetID]
      end
    rescue Twitter::Error::NotFound
      # If tweet not found, remove it from the database
      # TO DO : Move SQL query to other file
      $db.execute(%{DELETE FROM customer_tweets WHERE tweet_id = '#{t[0]}'})
    end
    i = i + 1
  end
  
  # Return the list of usable tweets in reverse order
  # (most recent will be displayed at the top)
  return displayTweets.reverse
end

def updateDatabase()
  # DEBUG : Display current status  
  puts "    <--- Executing updateDatabase() --->"
  
  # Get the 100 most recent tweets that mention ise19team12
  recentTweets = @client.mentions_timeline({:count => 100})
  
  # Get a list of all tweetIds that are currently in the database
  # TO DO : Move SQL query to other file
  #currentIDs = getStoredTweetIDs
  currentIDsFromDB = $db.execute(%{SELECT tweet_id FROM customer_tweets})
  
  # Put into one dimensional array
  currentIDs = []
  currentIDsFromDB.each do |t|
    currentIDs.push(t[0])
  end
  
  # For every new tweet, check if its id is already in the database
  # If it is, move on
  # If it is not, insert the tweetId into the database with the status 'Active'
  puts "Checking if any of the recent tweets are already in the database..."
  recentTweets.each do |t|
    if (!(currentIDs.include? t.id) && t.in_reply_to_status_id < 0)
      # DEBUG : Display current status
      puts "    Tweet is not currently in the database"
      
      # Gather data about the tweet
      tweetID = t.id
      status = 'Active'
      twitterHandle = t.user.screen_name
      username = t.user.name
      inReplyToTweetID = 0
      branch = 'unknown'
      
      # DEBUG : Display what is being added to the database
      puts "    Adding [#{t.id} #{status} #{twitterHandle} #{username} #{inReplyToTweetID} #{branch}] to database"
      
      # Add the tweet to the database
      # TO DO : Move SQL query to external file
      #insertNewCustomerTweet t.id, status, twitterHandle, inReplyToTweetID
      $db.execute(%{INSERT INTO customer_tweets VALUES(?, ?, ?, ?, ?, ?)}, 
                    tweetID, status, twitterHandle, username, inReplyToTweetID, branch)
    end
  end
end

# Method : showConversation
def showConversation(rootTweetID)
  # DEBUG : Display current status
  puts "    <--- Executing showConversation()... --->"
  puts "    rootTweetID: #{rootTweetID}"
  
  # Initialise tweet list
  tweetIDsInConversation = [rootTweetID]
  
  # Get geocode if there is one
  session[:geocode] = geocode(rootTweetID)
    
  # Get home address if there is one
  session[:home_address] = homeAddress(("@"+@client.status(rootTweetID).user.screen_name))

  # DEBUG : Display current contents of tweetIDsInConversation
  puts "tweetIDsInConversation: "
  puts "  #{tweetIDsInConversation[0]}"
  
  # Expand tweet list with existing tweets in database
  puts "  <--- Expanding conversation with tweets in database... --->"
  moreTweets = true
  i = 0
  
  # While there are more tweets in the conversation, get the ID of the next tweet in the conversation if there is one
  # If there is, add the tweetID to list of tweets in the conversation
  # If there isn't, then there are no more tweets in the conversation that are in the database
  while moreTweets == true do
    puts "  Checking for replies to tweet: #{tweetIDsInConversation[i]}"
    
    # TO DO : Move SQL query to other file
    #nextTweetID = getReplyFromDB(tweetIDsInConversation[i])
    nextTweetID = $db.execute(%{SELECT tweet_id FROM customer_tweets WHERE in_reply_to = '#{tweetIDsInConversation[i]}'})
    
    if nextTweetID[0].to_s.length != 0 
      # DEBUG : Display the ID of the new tweet
      puts "    Found a new tweet in the conversation: #{nextTweetID[0][0]}"
      
      # Add the new tweet ID to tweetIDsInConversation
      tweetIDsInConversation.push(nextTweetID[0][0])
      i = i + 1
    else
      # DEBUG : Report current status
      puts "    No more tweets in the conversation that are in the database"
      moreTweets = false          
    end
  end
  
  # Expand tweet list with new tweets on twitter
  puts "  <--- Expanding conversation with tweets on Twitter... --->"
  moreTweets = true

  # While there are more tweets in the conversation, get the ID of the next tweet in the conversation if there is one
  # If there is, add the tweetID to the database so that it can be found easier in the future, 
  # and add the tweetID to the list of tweets in the conversation
  # If there isn't, then there are no more tweets in the conversation
  while moreTweets == true do
    nextTweetID = getReplyFromTwitter(tweetIDsInConversation[i])
    
    # DEBUG : Display the ID of the new tweet
    puts "  Next tweet in conversation: #{nextTweetID}"
    
    if nextTweetID != 0
      # DEBUG : Report current status
      puts "    More replies found"
      
      # Fetch tweet data
      tweetID = nextTweetID
      status = 'Active'
      twitterHandle = @client.status(nextTweetID).user.screen_name
      username = @client.status(nextTweetID).user.name
      inReplyToTweetID = tweetIDsInConversation[i]
      branch = 'unknown'
      
      # DEBUG : Display what is being added to the database
      puts "    Adding [#{tweetID} #{status} #{twitterHandle} #{username} #{inReplyToTweetID} #{branch}] to database"
      
      # Add the tweet to the database
      # TO DO : Move SQL query to other file
      #insertNewCustomerTweet t.id, status, twitterHandle, inReplyToTweetID
      $db.execute(%{INSERT INTO customer_tweets VALUES(?, ?, ?, ?, ?, ?)}, 
                  tweetID, status, twitterHandle, username, inReplyToTweetID, branch)
      
      # DEBUG : Display what is being added to tweetIDsInConversation
      puts "    Adding #{tweetID} to conversation"
      
      # Add the new tweet ID to tweetIDsInConversation
      tweetIDsInConversation.push(nextTweetID)
      i = i + 1
    else
      # DEBUG : Display current status
      puts "    No more tweets in the conversation"
      moreTweets = false
      puts ""
    end
  end
  
  # Store the branch of the conversation for use in the Conversation Info box
  session[:conversationBranch] = $db.execute(%{SELECT branch FROM customer_tweets WHERE tweet_id = #{tweetIDsInConversation[0]}})[0][0]
  puts "session[:conversationBranch]: #{session[:conversationBranch]}"
  
  # Create an array of tweets in the conversation containing data that can be used by the view
  puts "Creating an array of tweets to use in the view..."
  conversation = []
  
  # For every tweet, get its data from the database
  # Store this data in conversation
  tweetIDsInConversation.each do |t|
    # TO DO : Move SQL query to other file
    tweet = $db.execute(%{SELECT * FROM customer_tweets WHERE tweet_id = #{t}})
    puts "  Tweet fetched from database: "
    puts "    #{tweet}"
    conversation.push([tweet[0][1], @client.status(tweet[0][0]).text, '@' + tweet[0][2], t])
  end
  
  return conversation
end

def getReplyFromTwitter(tweetID)
  # Checks the tweets the user who posted tweetID sent since sending tweetID to see if they replied to the tweetID
  
  # DEBUG : Display current status
  puts "    <--- Executing getReplyFromTwitter(#{tweetID})... --->"
  
  # DEBUG : Display the tweetID that is being searched for
  puts "tweetID: #{tweetID}"
  
  # Get the twitter handle of the customer
  #userHandle = @client.status(tweetID).user.screen_name
  userHandle = session[:conversationTwitterHandle]
  
  # DEBUG : Display the twitter handle
  puts "userHandle: #{userHandle}"
  
  # Get all tweets that userHandle has posted since tweetID was posted
  recentTweets = @client.user_timeline(userHandle, {:since_id => tweetID})
  
  # For every tweet, check if it is a reply to the passed tweets
  # If it is, return its tweet ID
  # If none of the tweets are replies, return 0
  puts "Analysing tweets by #{userHandle} to check for replies to #{tweetID}..."
  recentTweets.each do |t|
    if t.in_reply_to_status_id == tweetID
      puts "  Success: #{t.id} is in reply to tweetID"
      return t.id
    end
  end
  
  puts "  Failure: No recent tweets in reply to tweetID"
  return 0
end 

# Method : sendReply
def sendReply(message, inReplyTo)
  # DEBUG : Display current status
  puts "    <--- Executing sendReply(#{message}, #{inReplyTo})... --->"
  
  # Put tweet on twitter
  puts "Creating new reply tweet on Twitter..."
  @client.update(message, {:in_reply_to_status_id => inReplyTo})
  
  # Store the tweet
  replyTweet = @client.user_timeline({:count => 1})[0]
  replyTweetID = replyTweet.id
  puts "replyTweet: #{replyTweet} (#{replyTweetID})"
  
  # Add tweet to database
  puts "Adding reply to database:"
  tweetID = replyTweetID
  status = 'Active'
  twitterHandle = 'ise19team12'
  username = 'FakeTwaxi'
  inReplyToTweetID = inReplyTo
  branch = 'unknown'
  
  puts "  Adding: [#{tweetID} #{status} #{twitterHandle} #{username} #{inReplyToTweetID} #{branch}] to the database"
  # TO DO : Move SQL query to other file
  $db.execute(%{INSERT INTO customer_tweets VALUES(?, ?, ?, ?, ?, ?)}, 
              tweetID, status, twitterHandle, username, inReplyToTweetID, branch)
  
  # Update the conversation
  $conversation = showConversation(session[:conversation][0][3])
end

# Method : createRide
def createRide(rideOrigin, rideDestination, rideTwitterHandle)
  # Search users database for a matching account
  rideTwitterHandle = "@"+ rideTwitterHandle 
  results = $db.execute(%{SELECT username FROM users WHERE twitter_handle = '#{rideTwitterHandle}'})
  puts "results: #{results}"
    
  # If no matching account is found, continue
  # If there is a matching account, <increment their number of rides by once> and add the ride to the database
  #   If they have 10 rides accumulated, give them a free ride offer and set their username to "NONE"
  if results.length > 0
    rides = 1
    rideUsername = results[0]

    ###############################
    # ADD TO CUSTOMERS RIDE TALLY #
    ###############################
    
    # Create a new ride in the database
    currentTime = Time.new
    rideDate = currentTime.day.to_s + '/' + currentTime.month.to_s + '/' + currentTime.year.to_s
    
    $db.execute(%{INSERT INTO rides(username, date, departure, destination) VALUES(?, ?, ?, ?)},
                  rideUsername, rideDate, rideOrigin, rideDestination)
  end
    
  # Send an automated response tweet
  puts "Sending automatic tweet..."
  responseMessage = session[:conversationTwitterHandle] + " Your taxi is en route!"
  inReplyToTweetID = session[:conversation][session[:conversation].length-1][3]
  puts "   inReplyToTweetID: #{inReplyToTweetID}"
  sendReply(responseMessage, inReplyToTweetID)
  
  # Add this tweet to the conversation
   
  
  # Set the conversation as 'Handled'
  rootTweetID = session[:conversation][0][3]
  puts "rootTweetID: #{rootTweetID}"
  $db.execute(%{UPDATE customer_tweets SET status = 'Handled' WHERE tweet_id = '#{rootTweetID}'})
end

# Check if the Tweet has a geocode
# If it does finds the loaction using geocoder
def geocode (tweet_id)
    status = @client.status(tweet_id)
    if status.geo?
        lat = status.geo.lat
        long = status.geo.long
        puts "Lattitude: #{lat}"
        puts "Longitude: #{long}"
        results = Geocoder.search([lat, long])
        puts "Location #{results.first.address}"
      return results.first.address 
    else
        puts"Geo Code Not Found Please Enter Ask For location"
      return "No geocode found"
    end
end

def homeAddress (username)
    if checkTwitterHandleTaken username then
        begin 
            address =  $db.execute(%{SELECT home_address FROM users WHERE twitter_handle = ?}, username)[0][0]
        rescue NoMethodError 
            return address = "Not Found"
        end
        if address == "" then
            return address = "Not Found"
        else
            return address
        end
    else
       return "User Doesnt Exsist in Database"
    end
end