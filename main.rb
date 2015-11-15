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
      index :password
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
      integer     :device_id, null: false
      string      :event_type, default: false, null: false
      float       :amount, default: false, null: false
      timestamp   :event_time, null: false
      boolean     :ackd, null: false, default: false

      index :device_id
      index :event_type
      index :amount 
      index :event_time
    end
  end unless database.table_exists? :events
end

Sequel.connect('sqlite://slate.db')

class Users < Sequel::Model
end

class Device < Sequel::Model
end

class Event < Sequel::Model
  def to_json
    {
      device_id: device_id,
      event_type: event_type,
      amount: amount,
      event_time: event_time
    }.to_json
  end
end

configure do
  set :database, 'sqlite://slate.db'
  
  init_database

end

before do
  content_type 'application/json'
end

get "/" do
  { here: "Yes." }.to_json
end

get "/events/:event_id/ack" do
  Event[params[:event_id]].update(ackd: true)
  { done: "Yes" }.to_json
end

get "/events/:device_id" do
  database[:events].filter(device_id: params[:device_id], ackd: false).limit(10).to_a.to_json
end

get "/api/:device_id/:event_type/:amount" do
  "Error!" if not params.has_key?(:device_id) and params.has_key?(:event_type) and params.has_key?(:amount)
  Event.create(device_id: params[:device_id].to_i, event_type: params[:event_type], amount: params[:amount], event_time: DateTime.now)
  {done: "Yes"}.to_json
end

# JSONP Cross Origin Setup
def use_cross_origin
  cross_origin :allow_origin => '*',
    :allow_methods => [:get],
    :expose_headers => ['Content-Type', ]
end
