class ProfileComment < ActiveRecord::Base
  belongs_to :writer, class_name: User
  belongs_to :profile
end
