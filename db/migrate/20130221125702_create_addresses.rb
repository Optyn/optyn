class CreateAddresses < ActiveRecord::Migration
  def up
    create_table :addresses do |t|
      t.string :street_address1
      t.string :street_address2
      t.string :state
      t.string :city
      t.integer :merchant_id
      t.float :longitude
      t.float :latitude
      t.timestamps
    end
  end
  def down 
    drop_table :addresses
  end
end
