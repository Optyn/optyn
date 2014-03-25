object false

child :data do

  node :message do
    {:success => @success, :message => @message, :notice => @msg, :message_change_notifier =>  @message_change_notifier}
  end

end