object false

child :data do

  node :reject do
    {:success => @success,:message => @message,:message_change_notifier => @message_change_notifier, :access_token => params[:access_token],:manager_uuid => params[:manager_uuid],:errors => @error}
  end

end