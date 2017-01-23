class ArticleTag < ApplicationRecord
  belongs_to :article
  belongs_to :tag
  belongs_to :writer, class_name: User
  validates :tag_id, uniqueness: { scope: :article_id }
end
