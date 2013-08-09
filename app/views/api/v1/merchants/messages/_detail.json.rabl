attributes :uuid, :name, :content, :created_at, :state, :subject

node :message_type do |message|
  message.type.underscore
end unless locals[:message_instance].type.blank?

node :label_ids do |message|
  message.label_ids
end

node :errors do |message|
  message.errors.full_messages
end

node(:type_of_discount) do |message| 
  message.type_of_discount 
end unless locals[:message_instance].type_of_discount.blank?

node :discount_amount do |message|
  message.discount_amount
end unless locals[:message_instance].discount_amount.blank?

node :coupon_code do |message|
  message.coupon_code
end unless locals[:message_instance].coupon_code.blank?

node :permanent_coupon do |message|
  message.permanent_coupon
end unless locals[:message_instance].permanent_coupon.blank?

node :fine_print do |message|
  message.fine_print
end unless locals[:message_instance].fine_print.blank?

node :ending do |message|
  message.ending	
end unless locals[:message_instance].ending.blank?

node :special_try do |message|
  message.special_try
end unless locals[:message_instance].special_try.blank?

node :rsvp do |message|
  message.rsvp
end unless locals[:message_instance].rsvp.blank?

node :folder_counts do
  {:drafts => @drafts_count, :queued => @queued_count}
end

node :shop do |message|
  {name: message.shop.name, logo: message.shop.logo_location}
end

node :receivers do |message|
  {labels: message_receiver_labels(locals[:message_instance].label_names), count: locals[:message_instance].connections_count}
end if locals[:message_instance].sent? 

node :sent do |message|
  message_detail_date(locals[:message_instance])
end if locals[:message_instance].sent? 