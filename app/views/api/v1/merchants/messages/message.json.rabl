object @message => :data
attributes :uuid, :name, :content, :created_at, :state, :subject

node :message_type do |message|
  message.type.underscore
end unless @message.type.blank?

node :label_ids do |message|
  message.label_ids
end

node :errors do |message|
  message.errors.full_messages
end

node(:type_of_discount) do |message| 
  message.type_of_discount 
end unless @message.type_of_discount.blank?

node :discount_amount do |message|
  message.discount_amount
end unless @message.discount_amount.blank?

node :coupon_code do |message|
  message.coupon_code
end unless @message.coupon_code.blank?

node :permanent_coupon do |message|
  message.permanent_coupon
end unless @message.permanent_coupon.blank?

node :fine_print do |message|
  message.fine_print
end unless @message.fine_print.blank?

node :ending do |message|
  message.ending	
end unless @message.ending.blank?

node :special_try do |message|
  message.special_try
end unless @message.special_try.blank?

node :rsvp do |message|
  message.rsvp
end unless @message.rsvp.blank?