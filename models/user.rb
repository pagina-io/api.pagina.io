class User < Sequel::Model

  one_to_many :repos

  include Redis::Objects
  include Serializable
  include StandardModel

  self._readable = [:id, :auth_token, :created_at, :updated_at, :username, :avatar_url, :email, :github_id, :repos]
  self._writable = [:auth_token, :username, :avatar_url, :email]
  self._searchable = []
  self._exclude_from_search = []

  def authorized?(_access_token)
    return true if _access_token == self.auth_token
    false
  end

  def after_create
    if ENV['SMTP_SERVER']
      mailer = Mailer.new(
        to: ENV['EMAIL_ALERTS_TO'].split(','),
        subject: '[JIKKYLL]: New user has been registered',
        from: 'Jikkyllbot <apps@fiiv.io>',
        body: "A new user has been registered on Jikkyll.\nGithub username of #{self.username}\nJikkyll User ID: #{self.id}\nRegards,\n\njikkyllbot"
      )
      mailer.send!
    end
    super
  end

end
