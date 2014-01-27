class TemplateUpload < ActiveRecord::Base
  belongs_to :manager
  attr_accessible :template_html_file
  validates :template_html_file, presence: true

  def save_content
    template = Template.new
    template.html = self.template_html_file
    template.system_generated = false
    template.shop_id = Manager.select("shop_id").find(self.manager_id).shop_id
    template.save
  end
end
