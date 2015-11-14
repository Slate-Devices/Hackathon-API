require 'bundler/setup'
require "json"

Bundler.require

require 'sinatra/sequel'

def init_database
  migration "create the users table" do
    database.create_table :users do
      primary_key :id
      string      :email, null: false
      password    :password, null: false

      index :email, :unique => true
      index :password, :unique => true      
    end
  end unless database.table_exists? :users

  migration "create the devices table" do
    database.create_table :devices do
      primary_key :id
      string      :name, default: "New Device"
      string      :pairing_code, null: false
      boolean     :paired, default: false, null: false
      integer     :user_id

      index :pairing_code, :unique => true
      index :user_id
      index :paired      
    end
  end unless database.table_exists? :devices

  migration "create the events table" do
    database.create_table :events do
      primary_key :id
      string      :name, default: "New Device"
      integer     :device_id, null: false
      boolean     :severe, default: false, null: false
      timestamp   :event_time, null: false

      index :device_id
      index :severe
      index :event_time   
    end
  end unless database.table_exists? :events
end

configure do
  set :database, 'sqlite://slate.db'

  init_database

  disable :protection
end

before do
  content_type 'application/json'
end

get "/" do
  { here: "Yes." }.to_json
end

get "/event" do
  
end

# JSONP Cross Origin Setup
def use_cross_origin
  cross_origin :allow_origin => '*',
    :allow_methods => [:get],
    :expose_headers => ['Content-Type', ]
end
