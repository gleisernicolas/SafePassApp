class Api::V1::AuthController < Api::V1::ApiBaseController
  skip_before_action :authenticate_token

  def create
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      token = JsonWebToken.encode(sub: user.id)
      render json: { token: token }, status: :ok
    else
      render json: { errors: [ "Invalid Email or Password" ] }, status: :unauthorized
    end
  end
end
