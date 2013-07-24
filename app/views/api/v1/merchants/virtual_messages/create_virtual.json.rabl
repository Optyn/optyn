object @virtual_message => :data
attributes: :uuid, :name, :send_on, :subject, :from, :content

node :errors do |virtual_message|
    virtual_message.errors.full_messages rescue nil
end