module JikkyllHelpers

  def api_response(value = nil, status = :error)
    content_type detect_accept_header
    value.to_json
  end

  def detect_accept_header
    accepts = env['HTTP_ACCEPT'].split(',')
    return accepts.include?('application/json') ? :json : :text
  end

  def github_client
    @client = Octokit::Client.new(client_id: ENV['GITHUB_CLIENT_ID'], client_secret: ENV['GITHUB_SECRET'])
  end

  def github
    github_client
  end

end
