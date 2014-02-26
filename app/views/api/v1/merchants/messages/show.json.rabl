object false
child :data do

  node :select_list do
    {:labels => @labels}
   end

  node :folder_counts do
    {:drafts => @drafts_count, :queued => @queued_count}
  end

  child @message => :message do
  	extends('api/v1/merchants/messages/detail', :locals => { :message_instance => @message })

  	node false do
  	  {html: @rendered_string}
  	end

    node :receivers do
        {labels: message_receiver_labels(@message.label_names),count:@message.connections_count}
    end

    node :errors do
      @message.errors.full_messages
    end
  end
end

