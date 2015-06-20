class Repo < Sequel::Model

  many_to_one :user
  one_to_many :repofiles

  include Redis::Objects
  include Serializable
  include StandardModel

  self._readable = [:id, :created_at, :updated_at, :name, :description, :url, :repofiles]
  self._writable = []

  def authorized?(_access_token)
    return true if _access_token == self.auth_token
    false
  end

end
