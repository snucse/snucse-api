class TagRelation < ApplicationRecord
  belongs_to :tag
  belongs_to :related_tag, class_name: Tag
  belongs_to :writer, class_name: User
  validates :related_tag_id, uniqueness: { scope: :tag_id }

  default_scope { includes [:related_tag, :writer] }
end
