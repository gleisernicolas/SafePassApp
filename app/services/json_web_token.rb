module JsonWebToken
  SECRET_KEY = Rails.application.credentials.dig(:secret_key_base)

  def self.encode(payload, exp = 30.minutes.from_now.to_i)
    payload[:exp] = exp
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    JWT.decode(token, SECRET_KEY)[0]
  rescue JWT::ExpiredSignature
    { error: "Auth token has expired." }
  rescue JWT::DecodeError
    { error: "Invalid auth token." }
  end
end
