class Article < ActiveRecord::Base
  belongs_to :writer, class_name: User
  belongs_to :group
  has_many :comments
end
