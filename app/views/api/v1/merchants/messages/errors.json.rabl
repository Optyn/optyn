object @message => :data
node(:errors) do |message|
    message.error_messages
end