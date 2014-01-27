class TemplateUpload < ActiveRecord::Base
  belongs_to :manager
  belongs_to :template

  attr_accessible :template_html_file

  validates :template_html_file, presence: true
  mount_uploader :template_html_file, TemplateUploader

  def save_template
    template = Template.new
    template.html = self.template_html_file.read
    template.system_generated = false
    template.shop_id = Manager.select("shop_id").find(self.manager_id).shop_id
    template.save
    template
  end
end
