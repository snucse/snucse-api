class ArticleTag < ActiveRecord::Base
  belongs_to :article
  belongs_to :tag
end
