class Api::V1::ApiController < ApplicationController
  extend ParameterValidator
  skip_before_action :verify_authenticity_token
  before_action :check_api_key

  def check_api_key
    authenticate_or_request_with_http_token do |token, options|
      api_key = ApiKey.where(access_token: token).first
      if api_key.nil?
        render_unauthorized and return
      end
      if api_key and api_key.revoked?
        render status: 419, json: {
          message: "The token is revoked at: #{api_key.revoked_at.strftime("%Y-%m-%d %H:%M:%S")}"
        } and return
      end
      @user = api_key.user rescue nil
    end
  end

  def render_unauthorized
    render json: {}, status: :unauthorized
  end

  rescue_from Apipie::ParamError do |exception|
    error = exception.error rescue "required"
    json = {
      exception.param.name => error
    }
    render status: :bad_request, json: {
      errors: json
    }
  end
end
