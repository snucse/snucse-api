class Message < ApplicationRecord
  belongs_to :sender, class_name: User
  belongs_to :receiver, class_name: User

  default_scope { order id: :desc }

  STATUS_NOT_DELETED = 0
  STATUS_SENDER_DELETED = 1
  STATUS_RECEIVER_DELETED = 2

  def self.sender_not_deleted
    where.not(status: STATUS_SENDER_DELETED)
  end

  def self.receiver_not_deleted
    where.not(status: STATUS_RECEIVER_DELETED)
  end

  def sender_deleted?
    self.status == STATUS_SENDER_DELETED
  end

  def receiver_deleted?
    self.status == STATUS_RECEIVER_DELETED
  end

  def destroy_from_sender
    case self.status
    when STATUS_NOT_DELETED
      self.update_attributes(status: STATUS_SENDER_DELETED)
    when STATUS_SENDER_DELETED
    when STATUS_RECEIVER_DELETED
      self.destroy
    end
  end

  def destroy_from_receiver
    case self.status
    when STATUS_NOT_DELETED
      self.update_attributes(status: STATUS_RECEIVER_DELETED)
    when STATUS_SENDER_DELETED
      self.destroy
    when STATUS_RECEIVER_DELETED
    end
  end
end
