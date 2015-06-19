class Jikkyll < Sinatra::Base

  set :root, ENV['APP_ROOT']

  use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET']
  #use Rack::Throttle::Minute, :max => ENV['REQUEST_THROTTLE']
  use Rack::PostBodyContentTypeParser

  helpers JikkyllHelpers

  get '/' do
    api_response({ :name => 'Jikyll Alpha API', :version => ENV['JIKKYLL_VERSION'] })
  end

end
