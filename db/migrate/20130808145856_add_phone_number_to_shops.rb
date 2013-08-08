class AddPhoneNumberToShops < ActiveRecord::Migration
  def change
  	add_column(:shops, :phone_number, :string, default: "")
  end
end
