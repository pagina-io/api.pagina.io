class User < Sequel::Model

  one_to_many :repos

  include Redis::Objects
  include Serializable
  include StandardModel

  self._readable = [:id, :auth_token, :created_at, :updated_at, :username, :avatar_url, :email, :github_id, :repos]
  self._writable = [:auth_token, :username, :avatar_url, :email]
  self._searchable = []
  self._exclude_from_search = []

  def authorized?(_access_token)
    return true if _access_token == self.auth_token
    false
  end
  
  def self.current_user _access_token
    self.first(auth_token: _access_token)
  end

end
