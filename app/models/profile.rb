class Profile < ApplicationRecord
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

  def rendering_mode_label
    [nil, "text", "md", "html"][self.rendering_mode]
  end

  def rendered_description
    case self.rendering_mode
    when 1
      CGI.escapeHTML(self.description).gsub("\n", "<br>")
    when 2
      renderer = Redcarpet::Render::HTML.new
      markdown = Redcarpet::Markdown.new(renderer, tables: true, strikethrough: true)
      markdown.render(self.description)
    else
      self.description
    end
  end

  def set_rendering_mode(label)
    self.rendering_mode = {
      "text" => 1,
      "md" => 2,
      "html" => 3
    }[label]
    self.rendering_mode ||= 1
  end
end
