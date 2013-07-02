class VirtualConnection < ActiveRecord::Base
  belongs_to :user
  belongs_to :shop

  attr_accessible :user_id, :shop_id, :html_content, :state

  IN_PROCESS_STATE = "InProcess"
  ERROR_STATE = "Error"

  after_create :queue_connection_creation

  def self.create_real_connection
   # TODO TO BE IMPLEMENTED
   forms = self.html_content.scan(/(<form(.*?)<\/form>)/imx).collect(&:first)
  end

  private
  def queue_connection_creation
    Resque.enqueue(VirtualConnectionToRealConnector, self.id)
  end
end
