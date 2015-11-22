# Database!

DB = Sequel.connect(ENV['DATABASE_URL'])
DB.extension :pg_hstore
