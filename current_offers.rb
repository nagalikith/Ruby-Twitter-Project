get '/current_offers' do   
    @rows = displayoffers()
    erb :current_offers
end

def displayoffers()
    #Displays all offers in the table
    begin 
        rows = $db.execute(%{SELECT message FROM competition_tweets})
        return rows
    end
end