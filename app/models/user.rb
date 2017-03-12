class User < ApplicationRecord
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

  def valid_level?
    [LEVEL_ASSOCIATE, LEVEL_ACTIVE].include? self.level
  end

  def profile_image_uri
    if self.profile_image.file.nil?
      "/files/profile_images/default"
    else
      hash = "?#{Digest::SHA256.hexdigest(self.profile_image.thumb.read)[0..7]}" rescue nil
      "/files/profile_images/#{self.username}#{hash}"
    end
  end

  def is_birthday
    self.is_birthday_public and !self.is_birthday_lunar and !!self.birthday and self.birthday.strftime("%m-%d") == Date.today.strftime("%m-%d")
  end

  def set_information(new_information)
    information = JSON.parse(self.information) rescue Hash.new
    information.merge! new_information
    self.information = JSON.generate(information)
  end
end
