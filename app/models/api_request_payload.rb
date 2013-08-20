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

  private
  def assign_uuid
    IdentifierAssigner.assign_random(self, 'uuid')
  end
end
