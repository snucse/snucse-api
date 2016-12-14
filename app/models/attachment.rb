class Attachment < ActiveRecord::Base
  include LegacyPassword
  belongs_to :uploader, class_name: User
  belongs_to :article
  mount_uploader :file, FileUploader
  before_create :set_key

  def path
    "/files/#{self.key}/#{self.file_identifier}"
  end

  def set_key
    self.key = SecureRandom.urlsafe_base64(6)
  end
end
