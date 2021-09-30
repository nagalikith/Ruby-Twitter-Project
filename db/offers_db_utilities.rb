##offers_db_utilities.rb contains utilities for getting and checking data in the offers table.

#--------------------Getters--------------------

def getAccountOffers username
    return $db.execute(%{SELECT * FROM offers WHERE username = ?}, username)
end

def getAccountOffersOfType username, offer_type
    return $db.execute(%{SELECT * FROM offers WHERE username = ? AND offer_type = ?}, username, offer_type)
end

#--------------------Inserters--------------------

def createOffer username, offer_type
    $db.execute(%{INSERT INTO offers VALUES(?, ?)}, 
        username, offer_type)
end

#--------------------Deleters--------------------

def deleteOffer username, offer_type
    min_row_id = $db.execute(%{SELECT rowid FROM offers WHERE username = ? AND offer_type = ? ORDER BY rowid ASC}, username, offer_type)[0][0]
    puts min_row_id
    $db.execute(%{DELETE FROM offers WHERE rowid = ?}, min_row_id)
end
