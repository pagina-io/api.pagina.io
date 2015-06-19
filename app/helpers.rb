module JikkyllHelpers

  def api_response(value = {})
    content_type detect_accept_header
    value.to_json
  end

  def detect_accept_header
    accepts = env['HTTP_ACCEPT'].split(',')
    return accepts.include?('application/json') ? :json : :text
  end

  def github_client token
    Octokit::Client.new(access_token: token)
  end

  def get_access_token code
    query = {
      :body => {
        :client_id => ENV["GITHUB_CLIENT_ID"],
        :client_secret => ENV["GITHUB_SECRET"],
        :code => code
      },

      :headers => {
        'Accept' => 'application/json'
      }
    }

    token_request = HTTParty.post('https://github.com/login/oauth/access_token', query)
    JSON.parse(token_request.body)['access_token']
  end

end
