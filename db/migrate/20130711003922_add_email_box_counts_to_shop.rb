class AddEmailBoxCountsToShop < ActiveRecord::Migration
  def change
  	add_column :shops, :email_box_impression_count, :integer, default: 0
  	add_column :shops, :email_box_click_count, :integer, default: 0
  end
end
