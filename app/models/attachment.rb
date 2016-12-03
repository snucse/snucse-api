class Attachment < ActiveRecord::Base
  include LegacyPassword
  belongs_to :uploader, class_name: User
  belongs_to :article
  mount_uploader :file, FileUploader

  has_secure_password validations: false
  validates :password_digest, presence: true, if: "uploader_id.nil? and legacy_password_digest.nil?"
end
