class LegacyObject < ApplicationRecord
  belongs_to :target, polymorphic: true
end
