module Serializable

  attr_accessor :_access_token

  def self.included(base)
    base.extend ClassMethods
  end

  def authorized?(_access_token = nil)
    true # by default, allow access - implement method in actual models
  end

  def readable
    safe_params = {}

    self.class._readable.each do |param|
      safe_params[param] = send(param) unless param.nil?
    end

    safe_params
  end

  module ClassMethods
    attr_accessor :_readable
    attr_accessor :_writable

    def singular
      self.name.downcase
    end

    def readable
      select(_readable)
    end

    def authorized?(_access_token = nil)
      return false if _access_token.nil?
      User.first(auth_token: _access_token) ? true : false
    end

    def filter(params = {})
      safe_params = {}

      self._writable.each do |param|
        safe_params[param] = params[singular][param] if params[singular][param]
      end

      safe_params
    end

  end

end
