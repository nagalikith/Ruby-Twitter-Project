
get '/carmanager' do
    redirect '/' unless ["general_manager","car_manager"].include? session[:user_type]    
    @rows = displaycars()
    erb :carmanager
end

get '/carmanager_add' do 
    redirect '/' unless ["general_manager","car_manager"].include? session[:user_type]    
    unless params[:vehicle_id].nil? && params[:type_of_vehicle].nil? && params[:available].nil?
        vehicle_id = params[:vehicle_id]
        type_of_vehicle = params[:type_of_vehicle]
        available = params[:available]
        #Checks if the vehicle_id exsists in the Database 
        if checksVehicle(vehicle_id) then
            # If it exsists in the database then it deleltes and added new information to the database
            deleteFromDatabaseCar(vehicle_id)
            insertIntoDatabaseCar(vehicle_id,type_of_vehicle,available)
        else
            insertIntoDatabaseCar(vehicle_id,type_of_vehicle,available)
        end
    end
    redirect '/carmanager'
    erb :carmanager_add
end

get '/carmanager_remove' do 
    redirect '/' unless ["general_manager","car_manager"].include? session[:user_type]    
    unless params[:vehicle_id].nil? && params[:type_of_vehicle].nil? && params[:available].nil?
        vehicle_id = params[:vehicle_id]
        deleteFromDatabaseCar(vehicle_id)
        puts"Work done"
    end
    redirect '/carmanager'
    erb :carmanager_remove
end

def displaycars()
    begin
        # Gets all the Cars to display on the Dashboard
        region = getUserRegion session[:username]
        region = "\'#{region}\'"
        rows = $db.execute2 "SELECT * FROM CAR WHERE region = #{region}"
        rows.delete_at(0)
        return rows
    end
end

def deleteFromDatabaseCar vehicle_id
    $db.execute("DELETE FROM CAR WHERE vehicle_id = ?",vehicle_id)
end

def insertIntoDatabaseCar vehicle_id, type_of_vehicle, available
    region = getUserRegion session[:username]
    $db.execute("INSERT INTO CAR VALUES (?, ?, ?, ?)", 
        vehicle_id,type_of_vehicle,available,region)
end

def checksVehicle vehicle_id
    vehicle_ids = $db.execute "SELECT vehicle_id FROM CAR;"
    return vehicle_ids.include? [vehicle_id]
end
