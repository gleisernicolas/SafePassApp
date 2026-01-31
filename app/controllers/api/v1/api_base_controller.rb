class Api::V1::ApiBaseController < ApplicationController
  attr_reader :current_user

  skip_before_action :verify_authenticity_token
  before_action :set_json_format
  before_action :authenticate_token

  private

  def authenticate_token
    payload = JsonWebToken.decode(auth_token)
    if payload[:error]
      render json: { errors: [ payload[:error] ] }, status: :unauthorized
    else
      @current_user = User.find(payload["sub"])
    end
  end

  def auth_token
    @auth_token ||= request.headers["Authorization"]&.split(" ")&.last
  end

  def set_json_format
    request.format = :json
  end
end
