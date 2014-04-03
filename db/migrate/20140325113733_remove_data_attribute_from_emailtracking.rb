class RemoveDataAttributeFromEmailtracking < ActiveRecord::Migration
  def change
    remove_column :email_trackings, :data
  end
end
