require "data_mapper"

if ENV['VCAP_SERVICES'].nil?
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/dev.db")
else
  require 'json'
  svcs = JSON.parse ENV['VCAP_SERVICES']
  postgre = svcs.detect { |k,v| k =~ /^postgresql/ }.last.first
  creds = postgre['credentials']
  user, pass, host, name = %w(user password host name).map { |key| creds[key] }
  DataMapper.setup(:default, "postgres://#{user}:#{pass}@#{host}/#{name}")
end

class Snippet
  include DataMapper::Resource

  property :id, Serial
  property :title, Text, :required => true
  property :code, Text, :required => true
  property :language, Text, :required => true
end

DataMapper.finalize
DataMapper.auto_upgrade!
