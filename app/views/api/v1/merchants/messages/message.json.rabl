object false
child :data do

  node :select_list do
    {:labels => @labels}
  end	

  node :folder_counts do
    {:drafts => @drafts_count, :queued => @queued_count, :waiting_for_approval => @approves_count}
  end

  child @message => :message do
  	extends('api/v1/merchants/messages/detail', :locals => { :message_instance => @message })
  end
end

