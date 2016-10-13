class Tag < ActiveRecord::Base
  has_and_belongs_to_many :articles, -> { distinct }
  has_and_belongs_to_many :profiles, -> { distinct }
end
