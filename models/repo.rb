class Repo < Sequel::Model

  many_to_one :user
  one_to_many :repofiles

  include Redis::Objects
  include Serializable
  include StandardModel

  self._readable = [:id, :created_at, :updated_at, :name, :description, :url, :repofiles, :user_id]
  self._writable = [:name, :user_id]
  self._searchable = []

  def authorized?(_access_token)
    return true if _access_token == self.user.auth_token
    false
  end

  def before_create
    get_repo_from_github
    super
  end

  def after_create
    populate_files
    super
  end

  def before_destroy
    Repofile.where(repo_id: self.id).each {|f| f.destroy }
    super
  end

  def get_repo_from_github
    gh = Github.client(self.user.auth_token)
    gh_user = gh.user
    gh_repo = gh.repository("#{gh.user.login}/#{self.name}", :ref => 'gh-pages')

    self.user_id = User.first(github_id: gh.user[:id]).id rescue nil
    self.github_data = gh_repo.to_h
    self.description = gh_repo.description
    self.github_id = gh_repo.id
    self.url = gh_repo.url
  end

  def populate_files
    lookup_directory('/').each do |file|
      Repofile.create(file)
    end
  end

  def lookup_directory path
    gh = Github.client(self.user.auth_token)
    gh_files = gh.contents("#{gh.user.login}/#{self.name}", :path => path, :ref => 'gh-pages')

    result = []

    gh_files.each do |item|
      if item[:type] == 'file'
        result << {
          :filename => "#{item.path}",
          :repo_id => self.id
        }
      else
        (result << lookup_directory('/' + item[:path])).flatten!
      end
    end

    return result
  end

end
