module Serializable

  attr_accessor :_access_token

  def self.included(base)
    base.extend ClassMethods
  end

  def authorized?(_access_token = nil)
    true # by default, allow access - implement method in actual models
  end

  def readable(search = false)
    safe_params = {}
    params = self.class._readable

    params.reject! {|k| self.class._exclude_from_search.include?(k) } if search

    params.each do |param|
      safe_params[param] = send(param) unless param.nil?
    end

    safe_params
  end

  module ClassMethods
    attr_accessor :_readable
    attr_accessor :_writable
    attr_accessor :_searchable
    attr_accessor :_exclude_from_search

    def singular
      self.name.downcase
    end

    def authorized?(_access_token = nil)
      return false if _access_token.nil?
      User.first(auth_token: _access_token) ? true : false
    end

    def search_using(params = {})
      searchables = {}

      params.each do |key, value|
        searchables.merge!(self.send(:"search_using_#{key.to_s}", value)) if self._searchable.include?(key)
      end

      self.where(searchables)
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
