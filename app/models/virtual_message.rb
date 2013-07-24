class VirtualMessage < Message
  attr_accessible :from, :subject, :content

  def self.persist_and_add_to_queue(shop, receiver, options={})
    virtual_message = new(options)
    ActiveRecord::Base.transaction do
      virtual_message.manager_id = shop.manager.id
      virtual_message.send_on = Time.now
      virtual_message.save!

      inbox_folder_id = MessageFolder.inbox_id
      message_instance_id = virtual_message.id
      receiver_identifier = receiver.id
      MessageUser.create_individual_entry(inbox_folder_id, message_instance_id, receiver_identifier)

      #Set the state of the message to sent
      virtual_message.state = 'sent'
      virtual_message.save
    end
    virtual_message
  end
end