class Repo < Sequel::Model

  include Redis::Objects
  include Serializable
  include StandardModel

  def authorized?(_access_token)
    return true if _access_token == self.auth_token
    false
  end

end
