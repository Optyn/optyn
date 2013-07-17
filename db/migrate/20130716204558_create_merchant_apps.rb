class CreateMerchantApps < ActiveRecord::Migration
  def change
    create_table :merchant_apps do |t|
      t.string :name
      	
      t.timestamps
    end
  end
end
