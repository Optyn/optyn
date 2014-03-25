class AddColumnToMessageChangeNotifier < ActiveRecord::Migration
  def change
  	add_column :message_change_notifiers, :access_token , :string
  end
end
