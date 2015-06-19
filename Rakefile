require 'rubygems'  unless defined?(Gem)
require 'bundler'  unless defined?(Bundler)
require 'open-uri'

Bundler.require
Dotenv.load

APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '.'))

ENV['RACK_ENV'] = 'development' if ENV['RACK_ENV'].nil?

require './initializers/postgres'
require './initializers/redis'

namespace :db do

  desc "Database table creation"
  task :setup do
    require "./config/schema"
  end

  desc "Drop all the tables"
  task :drop do
    DB.drop_table? :users
    DB.drop_table? :repo
  end

end
