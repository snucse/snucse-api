class Article < ActiveRecord::Base
  include LegacyPassword
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  belongs_to :writer, class_name: User
  has_and_belongs_to_many :profiles
  has_many :article_tags
  has_many :tags, through: :article_tags
  has_many :comments
  has_one :last_comment, -> { where(parent_comment_id: nil).order(id: :desc) }, class_name: Comment
  has_many :attachments

  validates :anonymous_name, presence: true, if: "writer_id.nil?"
  has_secure_password validations: false
  validates :password_digest, presence: true, if: "writer_id.nil? and legacy_password_digest.nil?"

  default_scope { order id: :desc }
  default_scope { includes article_tags: [:tag, :writer] }

  def rendering_mode_label
    [nil, "text", "md", "html"][self.rendering_mode]
  end

  def set_rendering_mode(label)
    self.rendering_mode = {
      "text" => 1,
      "md" => 2,
      "html" => 3
    }[label]
    self.rendering_mode ||= 1
  end

  def anonymous?
    self.writer_id.nil?
  end
end
