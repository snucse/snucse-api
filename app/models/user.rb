class User < ActiveRecord::Base
  has_secure_password validations: false
  has_many :follows
  has_many :profiles, through: :follows
  has_many :favorite_articles
  has_many :favorites, through: :favorite_articles, source: :article
  validates_uniqueness_of :username
  has_many :feeds, through: :groups, source: :articles
  validates :password_digest, presence: true, if: "legacy_password_digest.nil?"

  def check_password(password)
    if self.legacy_password_digest
      salt = self.legacy_password_digest[6..13].scan(/../).map{|x| x.to_i(16).chr}.join
      hash = self.legacy_password_digest[14..-1].downcase
      password2 = password.split(//).map{|x| x + "\x00"}.join
      if Digest::SHA512.new.update(password2 + salt) == hash
        self.update_attributes(
          legacy_password_digest: nil,
          password: password
        )
        return self
      else
        return false
      end
    end
    self.authenticate(password)
  end
end
