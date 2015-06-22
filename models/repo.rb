class Repo < Sequel::Model

  many_to_one :user
  one_to_many :repofiles

  include Redis::Objects
  include Serializable
  include StandardModel

  self._readable = [:id, :created_at, :updated_at, :name, :description, :url, :repofiles, :github_data, :user_id]
  self._writable = [:name]

  def authorized?(_access_token)
    return true if _access_token == self.user.auth_token
    false
  end

  def before_create
    get_repo_from_github
    super
  end

  def get_repo_from_github
    gh = Github.client(_access_token)
    gh_user = gh.user
    gh_repo = gh.repository("#{gh.user.login}/#{self.name}")

    self.user_id = User.first(github_id: gh.user[:id]).id rescue nil
    self.github_data = gh_repo.to_h
    self.description = gh_repo.description
  end

end
