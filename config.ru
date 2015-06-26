require 'rubygems'
require 'bundler'
require 'yaml'
require 'open-uri'
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
require './initializers/mail'

require './lib/github'
require './lib/model'
require './lib/serializer'
require './lib/mailer'
require './lib/rest'

require './models/user'
require './models/repo'
require './models/repofile'

require './app/helpers'
require './config/version'
require './app/jikkyll'

run Jikkyll
