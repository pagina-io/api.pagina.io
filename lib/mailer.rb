require 'digest/sha2'

class Mailer

  def initialize(attributes = {})
    if attributes != {}
      [:to, :from, :subject, :body].each do |attribute|
        mail.send(attribute, attributes[attribute]) if attributes[attribute]
      end
    end
  end

  def send!
    mail.message_id = generate_message_id
    mail.deliver! if attributes_set?
  end

  def to=(value)
    mail.to = value
  end

  def from=(value)
    mail.from = value
  end

  def subject=(value)
    mail.subject = value
  end

  def body=(value)
    mail.body = value
  end

  private

  def generate_message_id
    domain = ENV['SMTP_LOGIN'].split('@').last
    "#{Digest::SHA2.hexdigest(Time.now.to_i.to_s)}@#{domain}"
  end

  def attributes_set?
    return false if mail.body.nil? && mail.subject.nil? && mail.to.nil? && mail.from.nil?
    true
  end

  def mail
    @mail ||= Mail.new
  end

end
