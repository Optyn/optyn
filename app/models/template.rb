class Template < ActiveRecord::Base
  attr_accessible :shop_id, :system_generated, :name

  has_many :messages
  has_many :templates_sections
  has_many :sections, through: :templates_sections

  scope :fetch_system_generated, where(system_generated: true)

  scope :include_sections, includes(templates_sections: :section)

  def self.system_generated
    fetch_system_generated.include_sections
  end
end