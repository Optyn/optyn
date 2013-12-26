class MessagesSection < ActiveRecord::Base
  attr_accessible :message_id, :section_id, :content, :position

  belongs_to :message
  belongs_to :section

  after_create :adjust_positions

  after_destroy :adjust_after_destroy

  def self.create_for_section_type(options)
    new_section = Section.send(options['section_type'].to_s.to_sym)
    new_message = Message.for_uuid(options['message_id'])
    previous_messages_section = MessagesSection.find(options['previous_id'])
    create(section_id: new_section.id, message_id: new_message.id, position: (previous_messages_section.position + 1), content: new_section.content)
  end

  private
    def adjust_positions
      messages_sections = message.messages_sections
      relevant_messages_sections = messages_sections.select{|messages_section| messages_section.id != self.id && messages_section.position >= self.position}

      relevant_messages_sections.each do |messages_section|
        messages_section.update_attribute(:position, messages_section.position + 1)
      end
    end

    def adjust_after_destroy
      message = self.message
      messages_sections = message.messages_sections
      messages_sections.each_with_index do |messages_section, index|
        messages_section.update_attribute(:position, index + 1)
      end
    end
end
