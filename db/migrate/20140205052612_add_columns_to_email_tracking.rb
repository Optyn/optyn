class AddColumnsToEmailTracking < ActiveRecord::Migration
  def change
  	add_column :email_trackings, :message_id, :integer
  	add_column :email_trackings, :redirect_url, :string
  	add_column :email_trackings, :user_email, :string
  end
end
