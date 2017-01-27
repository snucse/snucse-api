class Vote < ApplicationRecord
  belongs_to :survey
  belongs_to :voter, class_name: User
end
