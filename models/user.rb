class User < Sequel::Model

  include Redis::Objects
  include Serializable
  include StandardModel

  self._readable = [:id, :auth_token, :created_at, :updated_at, :username, :avatar_url, :email, :github_id]
  self._writable = [:auth_token, :username, :avatar_url, :email]

  list :repos

  def authorized?(_access_token)
    return true if _access_token == self.auth_token
    false
  end

end
