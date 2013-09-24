object false
node :folder_counts do
  {:drafts => @drafts_count, :queued => @queued_count}
end
child @message=>:data do
	extends('api/v1/merchants/messages/detail', :locals => { :message_instance => @message })
end

