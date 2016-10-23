class ProfileTag < ActiveRecord::Base
  belongs_to :profile
  belongs_to :tag
  belongs_to :writer, class_name: User
  validates :tag_id, uniqueness: { scope: :profile_id }
end
