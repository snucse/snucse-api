class User < ActiveRecord::Base
  has_secure_password
  has_many :follows
  has_many :profiles, through: :follows
  has_many :favorite_articles
  has_many :favorites, through: :favorite_articles, source: :article
  validates_uniqueness_of :username
end
