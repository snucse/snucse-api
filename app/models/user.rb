class User < ApplicationRecord
  has_many :follows
  has_many :profiles, through: :follows
  has_many :favorite_articles
  has_many :favorites, through: :favorite_articles, source: :article
  validates_uniqueness_of :username
  has_many :feeds, through: :profiles, source: :articles
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

  def rendering_mode
    key = "user:#{self.id}:rendering_mode"
    $redis.get(key) || "md"
  end

  def set_information(new_information)
    information = JSON.parse(self.information) rescue Hash.new
    information["bs_number"] = new_information[:bs_number] unless new_information[:bs_number].nil?
    email = information["email"][0] rescue Hash.new
    email["email"] = new_information[:email] unless new_information[:email].nil?
    email["public"] = new_information[:is_email_public] unless new_information[:is_email_public].nil?
    information["email"] = [email]
    phone_number = information["phone_number"][0] rescue Hash.new
    phone_number["phone_number"] = new_information[:phone_number] unless new_information[:phone_number].nil?
    phone_number["public"] = new_information[:is_phone_number_public] unless new_information[:is_phone_number_public].nil?
    information["phone_number"] = [phone_number]
    self.information = JSON.generate(information)
  end

  def set_rendering_mode(rendering_mode)
    key = "user:#{self.id}:rendering_mode"
    $redis.set(key, rendering_mode)
  end
end
