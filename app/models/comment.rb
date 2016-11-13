class Comment < ActiveRecord::Base
  include LegacyPassword
  belongs_to :writer, class_name: User
  belongs_to :article, counter_cache: :comment_count

  validates :anonymous_name, presence: true, if: "writer_id.nil?"
  has_secure_password validations: false
  validates :password_digest, presence: true, if: "writer_id.nil? and legacy_password_digest.nil?"

  def anonymous?
    self.writer_id.nil?
  end
end
