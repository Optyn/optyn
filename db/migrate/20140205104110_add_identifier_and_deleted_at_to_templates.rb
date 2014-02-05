class AddIdentifierAndDeletedAtToTemplates < ActiveRecord::Migration
  def change
    add_column(:templates, :uuid, :string)
    add_column(:templates, :deleted_at, :datetime)
    add_index(:templates, :uuid, unique: true)
  end
end
