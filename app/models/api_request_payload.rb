class ApiRequestPayload < ActiveRecord::Base
  belongs_to :partner

  attr_accessible :controller, :action, :partner_id, :filepath, :stats, :status

  serialize :body, Hash
  serialize :stats, Array

  # Status will transfer from 'Queued' => 'Inprocess' => 'Processed'

  before_create :assign_uuid

  scope :for_partner, ->(partner_identifier) { where(partner_id: partner_identifier) }

  scope :by_uuid, ->(uuid) { where(uuid: uuid) }

  def self.for_uuid(uuid)
    by_uuid(uuid).first
  end

  private
  def assign_uuid
    IdentifierAssigner.assign_random(self, 'uuid')
  end
end
