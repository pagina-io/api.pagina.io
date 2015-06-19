class User < Sequel::Model

  include Redis::Objects
  include Serializable
  include StandardModel

  list :repos

  class << self

    def me access_token
      self.first(access_token: access_token)
    end

  end

end
