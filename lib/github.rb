class Github

  class << self

    def client token
      @client = Octokit::Client.new(access_token: token, auto_traversal: true, per_page: 100)
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

    def proxy meta, access_token
      payload = {
        :headers => {
          'Authorization' => "token #{access_token}",
          'Accept' => 'application/json',
          'User-Agent' => 'Jikkyll'
        }
      }

      request = HTTParty.send(meta[:method].downcase, "https://api.github.com#{meta[:uri]}", payload)
      JSON.parse(request.body)
    end

  end

end
