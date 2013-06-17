class AddColumnOptOutToMessageUser < ActiveRecord::Migration
  def change
  	add_column :message_users, :opt_out, :boolean
  end
end
