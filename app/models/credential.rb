class Credential < ActiveRecord::Base
  attr_accessible :description, :login, :name, :password, :url, :in_use, :default, :server_type
  validates_presence_of :name
  validates_presence_of :url
  validates_presence_of :login
  validates_presence_of :password
  validates_presence_of :server_type, :message => 'Please select a server type'
  # only one taverna server is enabled at a time
  def self.get_taverna_uri
    find_by_server_type_and_default_and_in_use("ts",true,true).url
  end
  def self.get_taverna_credentials
    T2Server::HttpBasic.new(find_by_server_type_and_default_and_in_use("ts",true,true).login, find_by_server_type_and_default_and_in_use("ts",true,true).password)
  end
end
