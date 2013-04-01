class Merchants::MessagesController < Merchants::BaseController
  before_filter :populate_message_type, only: [:new, :create, :edit, :update]

  def types
   #Do Nothing
  end

  def  new
    @message = Message.new
  end

  private
  def populate_message_type
    @message_type = Message.fetch_template_name(params[:message_type])
  end
end
