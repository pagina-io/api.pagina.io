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

  def readable(*args)
    context = super
    context.merge!(content: self.content) if args.include?(:single)
    context
  end

  def content=(_content)
    return nil if _content.nil? || self.filename.nil?
    self.new? ? create_file_content(_content) : update_file_content(_content)
  end

  def create_file _content
    gh = Github.client(self._access_token)
    gh.create_contents(
      repo_name,
      self.filename,
      "Jikkyll: creating #{self.filename}",
      Base64.strict_encode64(_content),
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
      Base64.strict_encode64(_content),
      :branch => 'gh-pages'
    )

    return _content
  end

  def content
    Base64.decode64(get_remote_content.content)
  end

  def most_recent_blob_hash
    get_remote_content.sha
  end

  def get_remote_content
    gh = Github.client(self.repo.user.auth_token)
    gh.contents(repo_name, :path => self.filename, :ref => 'gh-pages')
  end

  def repo_name
    "#{self.repo.user.username}/#{self.repo.name}"
  end

end
