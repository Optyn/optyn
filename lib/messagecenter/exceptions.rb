module Messagecenter
  module Exceptions
    class BackgroundJobException < StandardError
      def log
        begin
          Rails.logger.error("---" * 33)
          Rails.logger.error(message)
          Rails.logger.error(backtrace)
          Rails.logger.error("-x-" * 33)
        rescue Exception => e
          Rails.logger.error(e.message)
          Rails.logger.error(e.backtrace)
        end
      end
    end

    class MessageUserCreationException < BackgroundJobException
    end

    class EmailForwardingException < BackgroundJobException
    end
  end
end