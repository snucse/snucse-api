class Activity < ApplicationRecord
  belongs_to :actor, class_name: User
  belongs_to :profile
  belongs_to :article
  belongs_to :target, polymorphic: true

  default_scope { order id: :desc }
end
