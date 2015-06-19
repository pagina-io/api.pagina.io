module Serializable
  attr_accessor :_readable
  attr_accessor :_writable
  attr_accessor :_access_token

  def self.authorized?
    return false if _access_token.nil?
    true
  end

end
