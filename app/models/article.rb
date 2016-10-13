class Article < ActiveRecord::Base
  belongs_to :writer, class_name: User
  has_and_belongs_to_many :profiles
  has_and_belongs_to_many :tags, -> { distinct }
  has_many :comments
  has_one :last_comment, -> { order id: :desc }, class_name: Comment
end
