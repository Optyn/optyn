class RemoveShopAuditsTable < ActiveRecord::Migration
  def up
    drop_table :shop_audits
  end
end
