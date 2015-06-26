if ENV['SMTP_SERVER']
  Mail.defaults do
    delivery_method :smtp, {
      :address => ENV['SMTP_SERVER'],
      :port => ENV['SMTP_PORT'],
      :user_name => ENV['SMTP_LOGIN'],
      :password => ENV['SMTP_PASSWORD']
    }
  end
end
