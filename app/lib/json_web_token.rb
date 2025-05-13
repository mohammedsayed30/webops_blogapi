# app/lib/json_web_token.rb
class JsonWebToken
  SECRET_KEY = if Rails.env.test?
                              "virtualsecretkey"
  else
                             Rails.application.credentials.secret_key_base
  end

  def self.encode(payload, exp = 48.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError
    nil
  end
end
