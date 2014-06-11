class AddUserIdAndLabelIdAndOnlyLabelIdIndexToUserLabels < ActiveRecord::Migration
  def change
    add_index :user_labels, [:user_id, :label_id]
    add_index :user_labels, [:label_id]
  end
end
