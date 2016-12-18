class User < ActiveRecord::Base
  include LegacyPassword
  has_secure_password validations: false
  has_many :follows
  has_many :profiles, through: :follows
  has_many :favorite_articles
  has_many :favorites, through: :favorite_articles, source: :article
  validates_uniqueness_of :username
  has_many :feeds, through: :profiles, source: :articles
  validates :password_digest, presence: true, if: "legacy_password_digest.nil?"
  mount_uploader :profile_image, FileUploader

  LEVEL_ASSOCIATE = 1
  LEVEL_ACTIVE = 2

  def active?
    self.level == LEVEL_ACTIVE
  end

  def profile_image_uri
    "/files/profile_images/#{self.username}"
  end
end
