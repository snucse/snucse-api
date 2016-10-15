class ArticleTag < ActiveRecord::Base
  belongs_to :article
  belongs_to :tag
  validates :tag_id, uniqueness: { scope: :article_id }
end
