class TemplateMessage < Message
  attr_accessible :template_id

  validates :template_id, presence: true, on: :update
end