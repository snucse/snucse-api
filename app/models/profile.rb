class Profile < ActiveRecord::Base
  belongs_to :admin, class_name: User
  has_and_belongs_to_many :articles
  has_and_belongs_to_many :tags, -> { distinct }

  def self.find_by_sid(sid)
    profile = super
    raise ActiveRecord::RecordNotFound if profile.nil?
    profile
  end
end
