class AddColumnToAuthentications < ActiveRecord::Migration
  def up
    add_column :authentications,:account_type,:string
    add_column :authentications,:account_id,:integer
    add_column :merchants,:shop_name,:string
  end
end
