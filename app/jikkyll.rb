class Jikkyll < Sinatra::Base

  set :root, ENV['APP_ROOT']

  use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET']
  use Rack::PostBodyContentTypeParser

  helpers JikkyllHelpers
  register REST

  before do
    content_type :json
    headers(
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST', 'PUT', 'PATCH', 'DELETE']
    )
  end

  set :protection, false

  get '/' do
    api_response({ :name => 'Jikyll Alpha API', :version => ENV['JIKKYLL_VERSION'] })
  end

  get '/auth/github' do
    scopes = 'user,repo'
    redirect "https://github.com/login/oauth/authorize?client_id=#{ENV['GITHUB_CLIENT_ID']}&scope=#{scopes}"
  end

  get '/auth/github/callback' do
    access_token = get_access_token(params[:code])
    gh_user = github_client(access_token).user
    user = User.first(github_id: gh_user[:id])

    if user
      user.auth_token = access_token
      user.save
    else
      user = User.create(
        auth_token: access_token,
        ip: request.ip,
        github_data: gh_user.to_h,
        username: gh_user.login,
        email: gh_user.email,
        avatar_url: gh_user.avatar_url,
        github_id: gh_user.id
      )
    end

    redirect "#{ENV['FRONT_END']}?access_token=#{access_token}"
  end

  create_resource(User, 'users')
  create_resource(Repo, 'repos')
  create_resource(RepoFile, 'files')

end
