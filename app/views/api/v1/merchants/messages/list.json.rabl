collection @messages, :root => "data", :object_root => false
node(false){ |message| partial('api/v1/merchants/messages/detail', :object => message, :locals => {:message_instance => message})}
