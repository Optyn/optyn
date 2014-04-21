object false

child :data do
  child @messages => :messages do
    node(false){ |message| partial('api/v1/merchants/messages/detail', :object => message, :locals => {:message_instance => message})}
  end

  node :folder_counts do
    {:drafts => @drafts_count, :queued => @queued_count, :waiting_for_approval => @approves_count}
  end

  node :pagination do
    {:total_count => @messages.total_count,
      :offset => @messages.offset_value,
      :page => params[:page].blank? || params[:page].to_i == 0 ? 1 : params[:page].to_i, 
      :per_page => Message::PER_PAGE}
  end
end
