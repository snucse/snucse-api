class Article < ActiveRecord::Base
  include LegacyPassword
  belongs_to :writer, class_name: User
  has_and_belongs_to_many :profiles
  has_many :article_tags
  has_many :tags, through: :article_tags
  has_many :comments
  has_one :last_comment, -> { order id: :desc }, class_name: Comment

  validates :anonymous_name, presence: true, if: "writer_id.nil?"
  has_secure_password validations: false
  validates :password_digest, presence: true, if: "writer_id.nil? and legacy_password_digest.nil?"

  default_scope { order id: :desc }
  default_scope { includes article_tags: [:tag, :writer] }

  def anonymous?
    self.writer_id.nil?
  end
end
