class Api::V1::EntriesController < Api::V1::ApiBaseController
  def index
    render json: current_user.entries.order(:name)
  end
end
