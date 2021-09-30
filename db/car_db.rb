def deleteFromDatabaseCar vehicle_id
    $db.execute("DELETE FROM CAR WHERE vehicle_id = ?",vehicle_id)
end

def insertIntoDatabaseCar tweet_id, end_date, message
    $db.execute("INSERT INTO competition_tweets VALUES (?, ?, ?)", 
        vehicle_id,type_of_vehicle,available)
end

def checksVehicle vehicle_id
    vehicle_ids = $db.execute "SELECT vehicle_id FROM CAR;"
    return vehicle_ids.include? [vehicle_id]
end