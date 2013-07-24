object @message => :data
node :message do |message|
   message.to_s
end

node :errors do |errors|
  @errors
end