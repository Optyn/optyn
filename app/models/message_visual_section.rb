class MessageVisualSection < ActiveRecord::Base
  has_many :message_visual_properties

  attr_accessible :name

  scope :by_name, ->(name) { where(["message_visual_sections.name ILIKE :name", {name: name}]) }

  HEADER_SECTION = "Header"

  def self.header
  	by_name(HEADER_SECTION).first
  end

  def self.header_id
  	header.id
  end
end
