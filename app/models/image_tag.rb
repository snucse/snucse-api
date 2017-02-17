class ImageTag < ApplicationRecord
  belongs_to :attachment
  belongs_to :tag
  belongs_to :writer, class_name: User
end
