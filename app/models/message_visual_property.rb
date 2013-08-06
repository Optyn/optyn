class MessageVisualProperty < ActiveRecord::Base
  belongs_to :message
  belongs_to :message_visual_section

  attr_accessor :make_default

  attr_accessible :message_id, :message_visual_section_id, :property_key, :property_value, :make_default

  def self.header(message_id)
  	where(message_id: message_id, message_visual_section_id: MessageVisualSection.header_id)
  end

  def make_default
  	message.shop_header_background_color_hex == extract_hex_from_property
  end

  private
  def extract_hex_from_property
  	self.property_value.split(":").last.gsub(";", "").strip rescue ""
  end
end
