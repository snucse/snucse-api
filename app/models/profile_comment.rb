class ProfileComment < ActiveRecord::Base
  belongs_to :writer, class_name: User
  belongs_to :profile
  has_many :replies, class_name: ProfileComment, foreign_key: :parent_comment_id
  has_one :last_reply, -> { order id: :desc }, class_name: ProfileComment, foreign_key: :parent_comment_id
end
