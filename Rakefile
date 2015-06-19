require 'rubygems'  unless defined?(Gem)
require 'bundler'  unless defined?(Bundler)
require 'open-uri'

Bundler.require
Dotenv.load

APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '.'))

require './initializers/postgres'
require './initializers/redis'

ENV['RACK_ENV'] = 'development' if ENV['RACK_ENV'].nil?

namespace :db do

  desc "Database table creation"
  task :setup do
    require "./config/schema"
  end

end
