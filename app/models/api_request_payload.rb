class ApiRequestPayload < ActiveRecord::Base
  include UuidFinder

  belongs_to :partner
  belongs_to :manager

  attr_accessible :controller, :action, :partner_id, :filepath, :stats, :status, :manager_id, :label

  serialize :body, Hash
  serialize :stats, Array

  # Status will transfer from 'Queued' => 'Inprocess' => 'Processed'

  before_create :assign_uuid

  scope :for_partner, ->(partner_identifier) { where(partner_id: partner_identifier) }

  scope :for_manager, ->(manager_identifier) { where(manager_id: manager_identifier) }
  
  scope :for_controller_and_action, ->(controller_name, action_name) { where(controller: controller_name, action: action_name) }

  def self.shop_imports(partner_identifer)
    for_partner(partner_identifer).for_controller_and_action("shops", "import")
  end

  def self.consumer_imports(manager_identifier)
    for_manager(manager_identifier).for_controller_and_action("users", "import")
  end

  def self.user_imports_for_partner(partner_identifer)
    for_partner(partner_identifer).for_controller_and_action("users", "import")
    binding.pry
  end

  private
  def assign_uuid
    IdentifierAssigner.assign_random(self, 'uuid')
  end
end
