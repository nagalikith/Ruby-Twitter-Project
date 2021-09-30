require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'twitter'
require 'sqlite3'
require 'bcrypt'
require 'geocoder'

#db & utils
$db = SQLite3::Database.open 'db/_db.sqlite'
require_relative 'db/db.rb'

#/create_account, /deauthenticate_twitter_handle, /account_creation_form
require_relative 'create_account'
#/login, /logout
require_relative 'login'
#/my_account
require_relative 'my_account'
#/accountsmanager
require_relative 'accountsmanager'
#/marketmanager, /marketmanager_create, /marketmanager_end
require_relative 'marketmanager'
#/previousride
require_relative 'previousRides'
#/twittermanager
require_relative 'twittermanager'

require_relative 'carmanager'

require_relative 'current_offers'

include ERB::Util
set :bind, '0.0.0.0' # needed if you're running from Codio

enable :sessions
set :session_secret, 'XB5rwq6X4EDiQ'

before do
    twitterConfig = {
        :consumer_key => '9qDerCvGJ9ba4ytkcEb7ka7AN',
        :consumer_secret => 'uSTPU7tbMDyGBi00dynaFNLnnjkxQp5ZpZIcs7PJcdxSwiD4Gl',
        :access_token => '1092447480585904129-OZbiEGBbu7eZo9dt5D9jox6LKhFj1D',
        :access_token_secret => 'GUanf4PGLlLSFNSVQHTaYoHM0KzhtIcPZ3YhJa1vwG6Yq'
    }
    @client = Twitter::REST::Client.new(twitterConfig)
end

get '/' do 
    erb :index
end
