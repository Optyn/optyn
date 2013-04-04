class MessageLabel < ActiveRecord::Base
  belongs_to :message
  belongs_to :label

  attr_accessible :label_id, :message_id
end