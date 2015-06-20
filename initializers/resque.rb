Resque.configure do |config|

  config.redis = ENV['REDIS_URL'] || 'redis://localhost:6379/jikkyll'

end
