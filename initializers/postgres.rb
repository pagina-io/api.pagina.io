# Database!

if ENV['RACK_ENV'] == 'development'
  opts = {
    :adapter => 'postgres',
    :host => ENV['DB_HOST'],
    :database => ENV['DB_NAME'],
    :user => ENV['DB_USER'],
    :password => ENV['DB_PASS'],
    :max_connections => 10
  }
elsif ENV['RACK_ENV'] == 'production'
  opts = ENV['DATABASE_URL']
end

DB = Sequel.connect(opts)
DB.extension :pg_hstore
