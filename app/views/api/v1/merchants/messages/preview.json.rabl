object false
child :data do
  node :folder_counts do
    {:drafts => @drafts_count, :queued => @queued_count}
  end

  child @message => :message do
  	extends('api/v1/merchants/messages/detail', :locals => { :message_instance => @message })

  	node false do
  	  {html: @rendered_string}
  	end
  end
end

