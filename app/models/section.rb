class Section < ActiveRecord::Base
  attr_accessible :section_type, :content, :addable

  has_many :templates_sections
  has_many :templates, through: :templates_sections
  has_many :messages_sections
  has_many :messages, through: :messages_sections

  scope :addable, where(addable: true)

  class << self
    class_eval do
      if Section.table_exists?
        sections = Section.all
        sections.each do |section|
          define_method(section.section_type.underscore.to_sym) do
            eval("@@#{section.section_type.underscore.upcase} ||= section")
          end

          define_method("#{section.section_type.underscore}_id".to_sym) do
            section.id
          end

        end
      end
    end
  end #end of self block
end
