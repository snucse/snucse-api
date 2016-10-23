class Profile < ActiveRecord::Base
  belongs_to :admin, class_name: User
  has_and_belongs_to_many :articles
  has_many :profile_tags
  has_many :tags, through: :profile_tags
end
