class CreateShopAudits < ActiveRecord::Migration
  def change
    create_table :shop_audits do |t|
    	t.integer :shop_id
    	t.text :description
      t.timestamps
    end
  end
end
