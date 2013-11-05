class Merchants::RedeemCouponsController < Merchants::BaseController
  def redeem
    p "in redeem coupon"
    message_user = Encryptor.decrypt(params[:message_user]).split("--")
    message_id = message_user[0] if message_user[0]
    user_id = message_user[1] if message_user[1]
    @message = Message.find(message_id)
  end
end