##users_db_utilities.rb contains utilities for getting and checking data in the users table.

#--------------------Data formatters--------------------

def format_twitter_handle twitter_handle
    if twitter_handle[0] != "@"
        twitter_handle = "@" + twitter_handle
    end
    return twitter_handle
end

def format_username username
    return username.downcase
end

#--------------------Getters--------------------

def getAccountDetails username
    return $db.execute(%{SELECT * FROM users WHERE username = ?}, username)[0]
end

def getUserType username
    return $db.execute(%{SELECT user_type FROM users WHERE username = ?}, username)[0][0]
end

def getUserRegion username
    return $db.execute(%{SELECT region FROM users WHERE username = ?}, username)[0][0]
end

def getTwitterHandle username
    return $db.execute(%{SELECT twitter_handle FROM users WHERE username = ?}, username)[0][0]
end

def getUserByTwitterHandle twitter_handle
    return $db.execute(%{SELECT username FROM users WHERE twitter_handle = ?}, twitter_handle)[0][0]
end

#--------------------Checkers--------------------

def checkAccountExists username
    usernames = $db.execute "SELECT username FROM users;"
    return usernames.include? [username]
end

def checkAccountPassword username, password
    stored_password = $db.execute(%{SELECT password FROM users WHERE username = ?}, username)[0][0]
    hashed_password = BCrypt::Password.new stored_password
    return hashed_password == password
end

def checkTwitterHandleTaken twitter_handle
    twitter_handles = $db.execute(%{SELECT twitter_handle FROM users})
    return twitter_handles.include? [format_twitter_handle(twitter_handle)]
end

#--------------------Inserters--------------------

def createAccount username, twitter_handle, password
    #BCrypt returns a string that contains a hash and a salt that can be used to recreate a BCrypt password object later.
    hashed_password = (BCrypt::Password.create password).to_s
    twitter_handle = format_twitter_handle twitter_handle
    $db.execute(%{INSERT INTO users VALUES(?, ?, ?, ?, ?, ?)}, 
        username, twitter_handle, "customer","sheffield","NOT SET", hashed_password)
end

#--------------------Modifiers--------------------

def updateUserData oldususername, username, twitter_handle, user_type, region, home_address
    if twitter_handle != "" then
        $db.execute(%{UPDATE users SET username = ?, twitter_handle = ?, user_type = ?, region = ?, home_address = ? WHERE username = ?}, username, twitter_handle, user_type, region, home_address, oldususername)
    else
        $db.execute(%{UPDATE users SET username = ?, twitter_handle = NULL, user_type = ?, region = ? WHERE username = ?}, username, user_type, region, oldususername)
    end
end

def updateTwitterHandle username, new_twitter_handle
    $db.execute(%{UPDATE users SET twitter_handle = ? WHERE username = ?}, new_twitter_handle, username)
end

def updateHomeAddress username, new_home_address
    $db.execute(%{UPDATE users SET home_address = ? WHERE username = ?}, new_home_address, username)
end
    
##--------------------Deleters--------------------

def deleteAccount username    
    $db.execute(%{DELETE FROM users WHERE username = ?}, username)
end
