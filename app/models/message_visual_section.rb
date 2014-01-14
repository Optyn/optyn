class MessageVisualSection < ActiveRecord::Base
  has_many :message_visual_properties

  attr_accessible :name

  scope :by_name, ->(name) { where(["message_visual_sections.name ILIKE :name", {name: name}]) }

  HEADER_SECTION = "Header"
  FOOTER_SECTION = "Footer"

  class << self
    if MessageVisualSection.table_exists?
      sections = MessageVisualSection.all
      sections.each do |section|
        define_method(section.name.underscore.to_sym) do
          eval("@@#{section.name.upcase} ||= section")
        end

        define_method("#{section.name.underscore}_id") do
          section.id
        end
      end
    end
  end #end of self block
end
