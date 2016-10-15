class Tag < ActiveRecord::Base
  has_many :article_tags
  has_many :articles, through: :article_tags
  has_many :profile_tags
  has_many :profiles, through: :profile_tags

  def self.find_by_name(name)
    tag = super
    raise ActiveRecord::RecordNotFound if tag.nil?
    tag
  end
end
