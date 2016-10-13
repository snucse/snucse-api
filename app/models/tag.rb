class Tag < ActiveRecord::Base
  has_and_belongs_to_many :articles, -> { distinct }
  has_and_belongs_to_many :profiles, -> { distinct }

  def self.find_by_name(name)
    tag = super
    raise ActiveRecord::RecordNotFound if tag.nil?
    tag
  end
end
