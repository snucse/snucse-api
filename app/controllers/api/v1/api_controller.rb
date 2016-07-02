class Api::V1::ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user

  def set_user
    #FIXME the code below is for development only
    @user = User.find params[:current_user_id] rescue nil
  end

  def render_unauthorized
    render json: {}, status: :unauthorized
  end
end
