class Jikkyll < Sinatra::Base

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
    ({ :name => 'Jikyll Alpha API', :version => ENV['JIKKYLL_VERSION'] }).to_json
  end

  options '/*' do
    content_type :json
    ''
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

    redirect "#{ENV['FRONT_END']}?access_token=#{access_token}&username=#{gh_user.login}"
  end

  %w(get post).each do |method|
    send method.to_sym, '/git*' do
      metadata = {
        :method => request.env['REQUEST_METHOD'],
        :uri => request.env['REQUEST_PATH'][4..-1],
      }

      api_request = Github.proxy(metadata, params[:access_token])
      api_response({ :meta => metadata, :result => api_request })
    end
  end

  get '/users/:id/scanrepos/?' do
    gh = Github.client(params[:access_token])
    gh_repos = gh.repos

    repos_with_pages = []

    gh_repos.each do |repo|
      begin
        gh.pages(repo.full_name)
        if gh.contents(repo.full_name, :path => '/_config.yml', :ref => 'gh-pages')
          repos_with_pages << { :name => repo.name }
        end
      rescue Octokit::NotFound
        # Do nothing, since there is no pages for this repo
      end
    end

    api_response({ :repos => repos_with_pages })
  end

  create_resource(User, 'users')
  create_resource(Repo, 'repos')
  create_resource(Repofile, 'repofiles')

end
