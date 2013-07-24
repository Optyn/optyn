class AddPartnerIdToShops < ActiveRecord::Migration
  def change
    add_column(:shops, :partner_id, :integer)
    add_index(:shops, :partner_id)
  end
end
