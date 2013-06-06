class RemoveMerchantsModel < ActiveRecord::Migration
  def up
    drop_table :merchants
  end

  def down
  end
end
