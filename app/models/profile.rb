class Profile < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  belongs_to :admin, class_name: User
  has_and_belongs_to_many :articles
  has_many :profile_tags
  has_many :tags, through: :profile_tags
  has_many :profile_comments
  has_one :last_comment, -> { where(parent_comment_id: nil).order(id: :desc) }, class_name: ProfileComment
  default_scope { includes profile_tags: [:tag, :writer] }
end
