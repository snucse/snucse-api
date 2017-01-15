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

  TYPE_GROUP = 1
  TYPE_USER = 2

  def self.group_profiles
    where(profile_type: TYPE_GROUP)
  end

  def self.user_profiles
    where(profile_type: TYPE_USER)
  end

  def group?
    self.profile_type == TYPE_GROUP
  end

  def user?
    self.profile_type == TYPE_USER
  end
end
