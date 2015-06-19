# Database!
DB = Sequel.connect(
  :adapter => 'postgres',
  :host => ENV['DB_HOST'],
  :database => ENV['DB_NAME'],
  :user => ENV['DB_USER'],
  :password => ENV['DB_PASS'],
  :max_connections => 10,
  :logger => Logger.new('log/db.log')
)

DB.extension :pg_hstore
