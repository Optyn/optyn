object false
node :folder_counts do
  {:drafts => @drafts_count, :queued => @queued_count}
end
child @messages=>:data do
	node(false){ |message| partial('api/v1/merchants/messages/detail', :object => message, :locals => {:message_instance => message})}
end
