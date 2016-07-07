class User < ActiveRecord::Base
  has_secure_password
  has_many :follows
  has_many :groups, through: :follows
end
