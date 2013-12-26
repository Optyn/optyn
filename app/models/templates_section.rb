class TemplatesSection < ActiveRecord::Base
  attr_accessible :template_id, :section_id, :position

  belongs_to :template
  belongs_to :section

  default_scope order(:position)
end


