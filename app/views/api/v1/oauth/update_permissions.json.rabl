object @message => :data
node :message do |message|
   message
end

node :errors do |errors|
  @errors || []
end