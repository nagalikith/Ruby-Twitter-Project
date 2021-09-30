##customer_tweets_utilities.rb contains utilities for getting and checking data in the customer_tweets table.

#--------------------Getters--------------------

def getRepliesToTweetID tweet_id
    return $db.execute(%{SELECT * FROM customer_tweets WHERE in_reply_to = ?}, tweet_id)
end

def getStoredTweetIDs 
    return $db.execute(%{SELECT tweet_id FROM customer_tweets})
end

def getTweets()
    return $db.execute(%{SELECT * FROM customer_tweets WHERE status = 'Handled' OR status = 'Active'})
end

#--------------------Checkers--------------------

#--------------------Inserters--------------------

def insertNewCustomerTweet tweet_id, status, twitter_handle, in_reply_to
    username = getUserByTwitterHandle twitter_handle
    $db.execute(%{INSERT INTO customer_tweets VALUES(?, ?, ?, ?, ?)}, 
        tweet_id, status, twitter_handle, username, in_reply_to)
end

