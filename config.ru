require 'rubygems'
require 'bundler'
require 'yaml'
require 'open-uri'
require 'json'
require 'logger'
require 'base64'
require 'cgi'

Bundler.require
Dotenv.load

require 'will_paginate/sequel'
require 'sequel/extensions/pagination'

APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '.'))

require './initializers/postgres'
require './initializers/redis'

require './models/user'
require './models/repo'

require './app/helpers'
require './config/version'
require './app/jikkyll'

run Jikkyll
