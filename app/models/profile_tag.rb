class ProfileTag < ActiveRecord::Base
  belongs_to :profile
  belongs_to :tag
  validates :tag_id, uniqueness: { scope: :profile_id }
end
