class MessageActionsController < Merchants::BaseController
	before_filter :check_validity_before_rejection, only: [:reject,:approve]

 def reject
    if request.get?
      render(layout: 'email_feedback')
    elsif request.put?
      @message_change_notifier = MessageChangeNotifier.find(@message_change_notifier.id)
      @message_change_notifier.attributes = params[:message_change_notifier]
      @message_change_notifier.save
      @message.reject
      MessageRejectionWorker.perform_async(@message_change_notifier.id)
      render(layout: 'email_feedback')
    end
  end

  def approve
    render(layout: 'email_feedback')
  end

  def validate
  	@manager = Manager.where(uuid: params[:manager_uuid]).first
  	@message = Message.for_uuid(params[:message_uuid])
  	success = (@manager.present? && @message.present?) ? true :false
  	message = (@manager.present? || @message.present?) ? "" : "You dont have permission or the link has expired" 
  	render json: {success: success, message: message}
  end

  private
  def check_validity_before_rejection
    access_token, manager_uuid ,message_uuid, message_change_uuid = fetch_message_and_change_identifiers
    @message_change_notifier = MessageChangeNotifier.for_message_id_and_message_change_id(message_uuid, message_change_uuid)
    @message = (@message_change_notifier.message rescue nil)

    unless @message_change_notifier.present?
      flash[:notice] = "The link has expired. A moditfication to the message has been made. Please contact support@optyn.com if you are facing problems."
      redirect_to root_path
      false
    end
  end

  def fetch_message_and_change_identifiers
    plain_text = Encryptor.decrypt(params[:id])
    plain_text.split("--")
  end

end