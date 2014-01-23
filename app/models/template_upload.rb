class TemplateUpload < ActiveRecord::Base
  belongs_to :manager
  attr_accessible :template_html_file
  validates :template_html_file, presence: true
end
