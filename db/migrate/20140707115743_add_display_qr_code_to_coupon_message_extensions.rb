class AddDisplayQrCodeToCouponMessageExtensions < ActiveRecord::Migration
  def change
  	add_column :coupon_message_extensions, :display_qr_code, :boolean, :default => false
  end
end
