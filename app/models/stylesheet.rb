class Stylesheet < ActiveRecord::Base
  belongs_to :template

  attr_accessible :location, :name, :template_id

  scope :no_template, where(template_id: nil)

  scope :with_name_ink, where(name: 'ink')

  def self.ink
    no_template.with_name_ink.first
  end
end

