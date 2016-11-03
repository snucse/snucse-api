class Tag < ActiveRecord::Base
  belongs_to :creator, class_name: User
  has_many :article_tags
  has_many :articles, through: :article_tags
  has_many :profile_tags
  has_many :profiles, through: :profile_tags

  def check_and_deactivate
    self.update_attributes(active: false) if self.article_tags.empty? and self.profile_tags.empty?
  end
end
