class AddAffiliateTrackerPingedToShops < ActiveRecord::Migration
  def change
    add_column :shops, :affiliate_tracker_pinged, :boolean, default: false
  end
end
