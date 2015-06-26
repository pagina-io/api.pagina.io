class Repofile < Sequel::Model

  many_to_one :repo

  include Redis::Objects
  include Serializable
  include StandardModel

  self._readable = [:id, :created_at, :updated_at, :filename, :repo_id]
  self._writable = [:content, :filename, :repo_id]

  def authorized?(_access_token)
    return true if _access_token == self.repo.user.auth_token
    false
  end

  def before_destroy
    delete_file_content
    super
  end

  def before_save
    create_file('') unless self.content rescue false
    super
  end

  def readable(*args)
    context = super
    context.merge!(content: self.content) if args.include?(:single)
    context
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
      "Jikkyll: creating #{self.filename}",
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
      "Jikkyll: updating #{self.filename}",
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
      "Jikkyll: removing #{self.filename}",
      most_recent_blob_hash,
      :branch => 'gh-pages'
    )
  end

  def content
    Base64.decode64(get_remote_content.content) rescue nil
  end

  def most_recent_blob_hash
    get_remote_content.sha rescue nil
  end

  def get_remote_content
    gh = Github.client(self.repo.user.auth_token)
    gh.contents(repo_name, :path => self.filename, :ref => 'gh-pages')
  end

  def repo_name
    "#{self.repo.user.username}/#{self.repo.name}"
  end

end
