class CreateMerchantsLabels < ActiveRecord::Migration
  def change
    create_table :merchants_labels do |t|

      t.timestamps
    end
  end
end
