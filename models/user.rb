class User < Sequel::Model

  def before_save
    timestamps!
    super
  end

  def timestamps!
    self.created_at = DateTime.now if self.new?
    self.updated_at = DateTime.now
  end

end
