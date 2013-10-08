class MessageVisualSection < ActiveRecord::Base
  has_many :message_visual_properties

  attr_accessible :name

  scope :by_name, ->(name) { where(["message_visual_sections.name ILIKE :name", {name: name}]) }

  HEADER_SECTION = "Header"
  FOOTER_SECTION = "Footer"

  def self.header
  	by_name(HEADER_SECTION).first
  end

  def self.header_id
  	header.id
  end

  def self.footer
    by_name(FOOTER_SECTION).first
  end

  def self.footer_id
    footer.id
  end
end
