class User < ActiveRecord::Base
  has_secure_password
  has_many :follows
  has_many :profiles, through: :follows
  validates_uniqueness_of :username
end
