class Comment < ActiveRecord::Base
  include LegacyPassword
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  belongs_to :writer, class_name: User
  belongs_to :article, counter_cache: :comment_count
  has_many :replies, class_name: Comment, foreign_key: :parent_comment_id
  has_one :last_reply, -> { order id: :desc }, class_name: Comment, foreign_key: :parent_comment_id

  validates :anonymous_name, presence: true, if: "writer_id.nil?"
  has_secure_password validations: false
  validates :password_digest, presence: true, if: "writer_id.nil? and legacy_password_digest.nil?"

  def anonymous?
    self.writer_id.nil?
  end
end
