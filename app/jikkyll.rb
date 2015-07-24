class Jikkyll < Sinatra::Base

  use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET']
  use Rack::PostBodyContentTypeParser

  set :show_exceptions, false

  helpers JikkyllHelpers
  register REST

  before do
    content_type :json

    headers(
      'Access-Control-Allow-Origin' => ENV['FRONT_END'] || '*',
      'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
      'Access-Control-Allow-Credentials' => true,
      'Access-Control-Allow-Headers' => [
        'Access-Control-Allow-Origin',
        'Access-Control-Allow-Methods',
        'Access-Control-Allow-Headers',
        'Authorization',
        'Content-Type',
        'Access-Control-Allow-Credentials'
      ]
    )
  end

  set :protection, false

  get '/' do
    Oj.dump(({ :name => 'Jikyll Alpha API', :version => ENV['JIKKYLL_VERSION'] }), mode: :compat)
  end

  options '/*' do
    content_type :json
    ''
  end

  error do
    status 500
    Oj.dump(({ :status => 'error', :message => env['sinatra.error'] }), mode: :compat)
  end

  get '/auth/github' do
    scopes = 'user,repo'
    redirect "https://github.com/login/oauth/authorize?client_id=#{ENV['GITHUB_CLIENT_ID']}&scope=#{scopes}"
  end

  get '/auth/github/callback' do
    access_token = Github.get_access_token(params[:code])
    gh_user = Github.client(access_token).user
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

    redirect "#{ENV['FRONT_END']}/callback?access_token=#{access_token}&username=#{gh_user.login}&user_id=#{user.id.to_s}"
  end

  %w(get post).each do |method|
    send method.to_sym, '/git/*' do
      metadata = {
        :method => request.env['REQUEST_METHOD'],
        :uri => request.env['REQUEST_PATH'][4..-1],
      }

      api_request = Github.proxy(metadata, params[:access_token])
      api_response({ :meta => metadata, :result => api_request })
    end
  end

  get '/github/repos/?' do
    gh = Github.client(params[:access_token])
    gh_repos = gh.repos

    repos = []

    gh_repos.each do |repo|
      repos << { :name => repo.name, :owner => repo.owner.login }
    end

    api_response({ :repos => repos })
  end

  get '/github/repos/:owner/:repo/?' do
    gh = Github.client(params[:access_token])
    repo = "#{params[:owner]}/#{params[:repo]}"

    response = []

    begin
      gh.pages(repo)
      if gh.contents(repo, :path => '/_config.yml', :ref => 'gh-pages')
        response = { gh_pages: true }
      else
        response = { gh_pages: false }
      end
    rescue Octokit::NotFound
      response = { gh_pages: false }
    end

    api_response({ :repos => response })
  end

  create_resource(User, 'users')
  create_resource(Repo, 'repos')
  create_resource(Repofile, 'repofiles')

end
