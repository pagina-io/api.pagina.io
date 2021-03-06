class Repo < Sequel::Model

  many_to_one :user
  one_to_many :repofiles

  include Redis::Objects
  include Serializable
  include StandardModel

  self._readable = [:id, :created_at, :updated_at, :name, :owner, :description, :url, :repofiles, :user_id]
  self._writable = [:name, :user_id, :owner]
  self._searchable = [:name, :user_id]
  self._exclude_from_search = []

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
    gh_repo = gh.repository("#{self.owner}/#{self.name}", :ref => 'gh-pages')

    self.user_id = User.first(github_id: gh.user[:id]).id rescue nil
    self.github_data = gh_repo.to_h
    self.description = gh_repo.description
    self.github_id = gh_repo.id
    self.url = gh_repo.url
  end

  def populate_files
    lookup_directory('/').each do |file|
      repo_file = Repofile.new(file)
      repo_file.dont_get_content = true
      repo_file.save
    end
  end

  def lookup_directory path
    gh = Github.client(self.user.auth_token)
    gh_files = gh.contents("#{self.owner}/#{self.name}", :path => path, :ref => 'gh-pages')

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

  def self.search_using_name _name
    { :name => _name }
  end

  def self.search_using_user_id _user_id
    { :user_id => _user_id }
  end

  def self.imported? name, owner
    self.where(name: name, owner: owner).count > 0
  end

end
