class Repofile < Sequel::Model

  many_to_one :repo

  include Redis::Objects
  include Serializable
  include StandardModel

  self._readable = [:id, :created_at, :updated_at, :filename, :repo_id, :content]
  self._writable = [:content, :filename, :repo_id]
  self._searchable = [:repo_name, :filename]
  self._exclude_from_search = [:content]

  def authorized?(_access_token)
    return true if _access_token == self.repo.user.auth_token
    false
  end

  def before_destroy
    delete_file_content
    super
  end

  def before_save
    (create_file('') unless self.content rescue false) unless self.new?
    super
  end

  def content
    Base64.decode64(get_remote_content.content) rescue nil
  end

  def content=(_content)
    return nil if _content.nil? || self.filename.nil?
    self.new? || most_recent_blob_hash.nil? ? create_file(_content) : update_file_content(_content)
  end

  def create_file _content
    gh = Github.client(self._access_token)
    gh.create_contents(
      repo_name,
      self.filename,
      "#{ENV['APP_NAME']}: creating #{self.filename}",
      _content,
      :branch => 'gh-pages'
    )

    return _content
  end

  def update_file_content _content
    gh = Github.client(self._access_token)

    gh.update_contents(
      repo_name,
      self.filename,
      "#{ENV['APP_NAME']}: updating #{self.filename}",
      most_recent_blob_hash,
      _content,
      :branch => 'gh-pages'
    )

    return _content
  end

  def delete_file_content
    gh = Github.client(self._access_token)

    gh.delete_contents(
      repo_name,
      self.filename,
      "#{ENV['APP_NAME']}: removing #{self.filename}",
      most_recent_blob_hash,
      :branch => 'gh-pages'
    )
  end

  def most_recent_blob_hash
    get_remote_content.sha rescue nil
  end

  def get_remote_content
    gh = Github.client(self.repo.user.auth_token)
    gh.contents(repo_name, :path => self.filename, :ref => 'gh-pages')
  end

  def repo_name
    "#{self.repo.owner}/#{self.repo.name}"
  end

  def self.search_using_repo_name _name
    _repo_id = Repo.first(name: _name).id
    { :repo_id => _repo_id }
  end

  def self.search_using_filename _name
    { :filename => _name }
  end

end
