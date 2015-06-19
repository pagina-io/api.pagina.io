class Jikkyll < Sinatra::Base

  set :root, ENV['APP_ROOT']

  use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET']
  use Rack::PostBodyContentTypeParser

  helpers JikkyllHelpers

  get '/' do
    api_response({ :name => 'Jikyll Alpha API', :version => ENV['JIKKYLL_VERSION'] })
  end

  get '/auth/github' do
    redirect "https://github.com/login/oauth/authorize?client_id=#{ENV['GITHUB_CLIENT_ID']}"
  end

  get '/auth/github/callback' do
    
  end

end
