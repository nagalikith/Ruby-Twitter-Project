##competition_tweets_utilities.rb contains utilities for getting and checking data in the competition_tweets table.

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

def insertNewCompetitionTweet tweet_id, end_date, message, region
    $db.execute("INSERT INTO competition_tweets VALUES (?, ?, ?, ?)", 
        tweet_id, end_date, message,region)
end