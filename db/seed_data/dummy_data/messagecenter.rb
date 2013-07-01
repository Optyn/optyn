general_messages = [
    {name: "CouchDB 1.3.0 Adds New", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100})},
    {name: "Google's Go Readies", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100})},
    {name: "BDD Tool Cucumbers", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100})},
    {name: "Product Backlogs", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100})},
    {name: "Dart2js Outperforms", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100})},
]

Manager.all.each do |manager|
  general_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = GeneralMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
    message.update_attribute(:send_on, Date.yesterday)
    message.launch
  end
end

product_messages = [
    {name: "IBM Mobile", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), special_try: '1'},
    {name: "Scaling Agile", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), special_try: '0'},
    {name: "Microsoft Office", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), special_try: '1'},
    {name: "Blossom Switches", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), special_try: '1'},
    {name: "Struts 1", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), special_try: '0'},
]

Manager.all.each do |manager|
  product_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = ProductMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
    message.update_attribute(:send_on, Date.yesterday)
    message.launch
  end
end

event_messages = [
    {name: "Gartner's Technology", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 5.days.since.to_s, rsvp: %Q(#{"This is the rsvp print" * 100})},
    {name: "Visual Studio 2012", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 6.days.since.to_s, rsvp: %Q(#{"This is the rsvp print" * 100})},
    {name: "EZNamespaceExtensions.Net", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 7.days.since.to_s, rsvp: %Q(#{"This is the rsvp print" * 100})},
    {name: "WSO2 Developer", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 8.days.since.to_s, rsvp: %Q(#{"This is the rsvp print" * 100})},
    {name: "Improve DevOps", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 9.days.since.to_s, rsvp: %Q(#{"This is the rsvp print" * 100})},
]

Manager.all.each do |manager|
  event_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = EventMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
    message.update_attribute(:send_on, Date.yesterday)
    message.launch
  end
end

sale_messages = [
    {name: "Developing Stable", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 5.days.since.to_s},
    {name: "Google, Opera Fork", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 6.days.since.to_s},
    {name: "Martin Fowler", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 7.days.since.to_s},
    {name: "Python Tools", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 8.days.since.to_s},
    {name: "Patent Holder", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 9.days.since.to_s},
]

Manager.all.each do |manager|
  sale_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = SaleMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
    message.update_attribute(:send_on, Date.yesterday)
    message.launch
  end
end

special_messages = [
    {name: "RSA Panelists", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 5.days.since.to_s, fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "Video Lessons", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 6.days.since.to_s, fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "Got Node?", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 7.days.since.to_s, fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "MongoDB", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 8.days.since.to_s, fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "Business Process", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 9.days.since.to_s, fine_print: %Q(#{"This is the fine print" * 100})},
]

Manager.all.each do |manager|
  special_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = SpecialMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
    message.update_attribute(:send_on, Date.yesterday)
    message.launch
  end
end

coupon_messages = [
    {name: "QCon New York", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), type_of_discount: "percentage_off", discount_amount: '10', coupon_code: '1234asdf', fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "Google Promises", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), type_of_discount: "dollar_off", discount_amount: '10', fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "GCC 4.8 Completes", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), type_of_discount: "percentage_off", discount_amount: '20', coupon_code: '1234asdf', fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "EclipseCon 2013", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), type_of_discount: "dollar_off", discount_amount: '30', coupon_code: 'asdf', fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "Release Cadence", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), type_of_discount: "percentage_off", discount_amount: '10', fine_print: %Q(#{"This is the fine print" * 100})},
]

Manager.all.each do |manager|
  coupon_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = CouponMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
    message.update_attribute(:send_on, Date.yesterday)
    message.launch
  end
end

Message.batch_send