class AddNameToTemplateUploads < ActiveRecord::Migration
  def change
    add_column(:template_uploads, :name, :string)
  end
end
