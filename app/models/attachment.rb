class Attachment < ActiveRecord::Base
  include LegacyPassword
  belongs_to :uploader, class_name: User
  belongs_to :article
  mount_uploader :file, FileUploader
end
