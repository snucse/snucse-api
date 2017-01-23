class ApiKey < ApplicationRecord
  belongs_to :user
  before_create :generate_access_token

  def revoked?
    self.revoked_at != nil
  end

  def revoke!
    self.update_attributes(revoked_at: Time.now)
  end

private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end
end
