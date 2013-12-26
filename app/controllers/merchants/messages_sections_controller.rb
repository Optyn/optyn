class Merchants::MessagesSectionsController < Merchants::BaseController
  #TODO Add appropriate before filters
  before_filter :current_message

  def create
    previous_position = params[:previous_position]
    section_type = params[:section_type]
    messages_section = MessagesSection.create_for_section_type(params)
    render partial: "individual_section", locals: {messages_section: messages_section}
  end

  def update
    messages_section = current_message.messages_sections.find(params[:id])
    messages_section.update_attributes!(params[:messages_section])
    head :ok
  rescue Exception => e
    head :unprocessible_entity
  end

  def destroy
    @messages_section = MessagesSection.find(params[:id])
    @messages_section.destroy
    head :ok
  end

  private
    def current_message
      @message ||= Message.for_uuid(params[:message_id]) 
    end
end
