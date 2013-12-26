class AddTemplateIdToMessages < ActiveRecord::Migration
  def up
    change_table(:messages) do |t|
      t.references :template
    end
  end

  def down
    change_table(:messages) do |t|
      t.remove_references :template
    end
  end
end
