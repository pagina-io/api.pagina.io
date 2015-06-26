class Repofile < Sequel::Model

  many_to_one :repo

  include Redis::Objects
  include Serializable
  include StandardModel

  self._readable = [:id, :created_at, :updated_at, :filename, :repo_id]
  self._writable = [:content, :filename]

  def authorized?(_access_token)
    return true if _access_token == self.repo.user.auth_token
    false
  end

  def readable(*args)
    context = super
    context.merge!(content: self.content) if args.include?(:single)
    context
  end

  def self.content=(data)
    gh = Github.client(self.repo.user.auth_token)

  end

  def content
    gh = Github.client(self.repo.user.auth_token)
    gh_content = gh.contents(repo_name, :path => self.filename, :ref => 'gh-pages')
    Base64.decode64(gh_content.content).to_s
  end

  def repo_name
    "#{self.repo.user.username}/#{self.repo.name}"
  end

end
