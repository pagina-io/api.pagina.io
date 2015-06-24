class User < Sequel::Model

  one_to_many :repos

  include Redis::Objects
  include Serializable
  include StandardModel

  self._readable = [:id, :auth_token, :created_at, :updated_at, :username, :avatar_url, :email, :github_id, :repos]
  self._writable = [:auth_token, :username, :avatar_url, :email]

  list :repos

  def authorized?(_access_token)
    return true if _access_token == self.auth_token
    false
  end

  def after_create
    mailer = Mailer.new(
      to: ['mike.timofiiv@gmail.com', 'jikkyll@adriaan.io'],
      subject: '[JIKKYLL]: New user has been registered!',
      from: 'apps@fiiv.io',
      body: "A new user has been registered on Jikkyll!"
    )
    mailer.send!
    super
  end

end
