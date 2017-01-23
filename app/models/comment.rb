class Comment < ApplicationRecord
  include LegacyPassword
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  belongs_to :writer, class_name: User
  belongs_to :article
  has_many :replies, class_name: Comment, foreign_key: :parent_comment_id
  has_one :last_reply, -> { order id: :desc }, class_name: Comment, foreign_key: :parent_comment_id
  belongs_to :parent_comment, class_name: Comment
  after_create :increment_count
  after_destroy :decrement_count

  validates :anonymous_name, presence: true, if: "writer_id.nil?"
  has_secure_password validations: false
  validates :password_digest, presence: true, if: "writer_id.nil? and legacy_password_digest.nil?"

  def anonymous?
    self.writer_id.nil?
  end

private

  def increment_count
    if self.parent_comment_id.nil?
      self.article.increment!(:comment_count)
    else
      self.parent_comment.increment!(:reply_count)
    end
  end

  def decrement_count
    if self.parent_comment_id.nil?
      self.article.decrement!(:comment_count)
    else
      self.parent_comment.decrement!(:reply_count)
    end
  end
end
