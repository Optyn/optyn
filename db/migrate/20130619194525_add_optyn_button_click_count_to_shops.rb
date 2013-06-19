class AddOptynButtonClickCountToShops < ActiveRecord::Migration
  def change
    add_column(:shops, :button_click_count, :integer)
  end
end