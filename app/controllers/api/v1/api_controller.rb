class Api::V1::ApiController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  extend ParameterValidator
  before_action :check_api_key, :check_user_level

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

  def check_user_level
    render json: {}, status: :forbidden unless @user and @user.active?
  end

  def render_unauthorized
    render json: {}, status: :unauthorized
  end

  rescue_from Apipie::ParamMissing do |exception|
    json = {
      exception.param.name => "required"
    }
    render status: :bad_request, json: {
      errors: json
    }
  end

  rescue_from Apipie::ParamInvalid do |exception|
    json = {
      exception.param.to_s => "invalid"
    }
    render status: :bad_request, json: {
      errors: json
    }
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render status: :not_found, json: {}
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    render status: :bad_request, json: {
      errors: exception.record.errors.messages
    }
  end
end
