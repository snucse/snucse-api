class ProfileComment < ApplicationRecord
  belongs_to :writer, class_name: User
  belongs_to :profile
  has_many :replies, class_name: ProfileComment, foreign_key: :parent_comment_id
  has_one :last_reply, -> { order id: :desc }, class_name: ProfileComment, foreign_key: :parent_comment_id
  belongs_to :parent_comment, class_name: ProfileComment
  after_create :increment_count
  after_destroy :decrement_count

private

  def increment_count
    if self.parent_comment_id.nil?
      self.profile.increment!(:comment_count)
    else
      self.parent_comment.increment!(:reply_count)
    end
  end

  def decrement_count
    if self.parent_comment_id.nil?
      self.profile.decrement!(:comment_count)
    else
      self.parent_comment.decrement!(:reply_count)
    end
  end
end
