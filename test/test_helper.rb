ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def set_access_token(token="abcdef0123456789abcdef")
    @request.headers["Authorization"] = "Token token=\"#{token}\""
  end

  def set_incorrect_access_token
    set_access_token("0123456789abcdef")
  end

  def set_revoked_access_token
    set_access_token("fedcba9876543210fedcba")
  end
end
