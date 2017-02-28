class Tag < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  belongs_to :creator, class_name: User
  has_many :article_tags
  has_many :articles, through: :article_tags
  has_many :profile_tags
  has_many :profiles, through: :profile_tags
  has_many :tag_relations

  def check_and_deactivate
    self.update_attributes(active: false) if self.article_tags.empty? and self.profile_tags.empty?
  end

  def recent_articles
    self.articles.limit(100)
  end
end
