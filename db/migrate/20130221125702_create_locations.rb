class CreateLocations < ActiveRecord::Migration
  def up
    create_table :locations do |t|
      t.string :street_address1
      t.string :street_address2
      t.string :city
      t.references :state
      t.references :shop
      t.string :zip
      t.float :longitude
      t.float :latitude
      t.timestamps
    end
  end
  def down 
    drop_table :locations
  end
end
