module Merchants::MessagesHelper
  def formatted_message_form_send_on(message)
    if message.send_on.present?
      message.send_on.strftime('%m/%d/%Y %I:%M %p')
    end
  end
end
