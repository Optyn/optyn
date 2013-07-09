class CreateConnectionErrors < ActiveRecord::Migration
  def change
    create_table :connection_errors do |t|
      t.references :user
      t.references :shop
      t.text :error
      t.timestamps
    end
  end
end
