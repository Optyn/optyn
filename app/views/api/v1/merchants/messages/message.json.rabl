object @message => :data
attributes :uuid, :content, :created_at, :state

node :label_ids do |message|
  message.label_ids
end
