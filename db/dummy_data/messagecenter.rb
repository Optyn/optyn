general_messages = [
    {name: "CouchDB 1.3.0 Adds New", second_name: "CouchDB 1.3.0 Adds New Features and Algorithm Enhancements", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100})},
    {name: "Google's Go Readies", second_name: "Google's Go Readies 1.1 Release", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100})},
    {name: "BDD Tool Cucumbers", second_name: "BDD Tool Cucumber with a Larger Team", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100})},
    {name: "Product Backlogs", second_name: "Product Backlogs with Process Maps or Story Maps", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100})},
    {name: "Dart2js Outperforms", second_name: "Dart2js Outperforms Hand-Written", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100})},
]

Manager.all.each do |manager|
  general_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = GeneralMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
  end
end

product_messages = [
    {name: "IBM Mobile", second_name: "IBM Mobile First- MBaaS, Big Data", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), special_try: '1'},
    {name: "Scaling Agile", second_name: "Scaling Agile At Spotify: An Interview", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), special_try: '0'},
    {name: "Microsoft Office", second_name: "Microsoft Office Developer Tools", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), special_try: '1'},
    {name: "Blossom Switches", second_name: "Blossom Switches to Dart", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), special_try: '1'},
    {name: "Struts 1", second_name: "Struts 1 Reaches End Of Life", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), special_try: '0'},
]

Manager.all.each do |manager|
  product_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = ProductMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
  end
end

event_messages = [
    {name: "Gartner's Technology", second_name: "Gartner's Technology Trends for something", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 5.days.since.to_s, rsvp: %Q(#{"This is the rsvp print" * 100})},
    {name: "Visual Studio 2012", second_name: "Visual Studio 2012 Update 2 Formally Released", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 6.days.since.to_s, rsvp: %Q(#{"This is the rsvp print" * 100})},
    {name: "EZNamespaceExtensions.Net", second_name: "EZNamespaceExtensions.Net v2013", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 7.days.since.to_s, rsvp: %Q(#{"This is the rsvp print" * 100})},
    {name: "WSO2 Developer", second_name: "WSO2 Developer Studio 3.0", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 8.days.since.to_s, rsvp: %Q(#{"This is the rsvp print" * 100})},
    {name: "Improve DevOps", second_name: "Improve DevOps Cultures with Information Consolidation", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 9.days.since.to_s, rsvp: %Q(#{"This is the rsvp print" * 100})},
]

Manager.all.each do |manager|
  event_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = EventMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
  end
end

sale_messages = [
    {name: "Developing Stable", second_name: "Developing Stable Teams", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 5.days.since.to_s},
    {name: "Google, Opera Fork", second_name: "Google, Opera Fork WebKit.", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 6.days.since.to_s},
    {name: "Martin Fowler", second_name: "Martin Fowler on Software Design", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 7.days.since.to_s},
    {name: "Python Tools", second_name: "Python Tools for Visual Studio 2.0", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 8.days.since.to_s},
    {name: "Patent Holder", second_name: "Patent Holder Pursues IP Grab on TCP/IP", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 9.days.since.to_s},
]

Manager.all.each do |manager|
  sale_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = SaleMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
  end
end

special_messages = [
    {name: "RSA Panelists", second_name: "RSA Panelists Reinforce", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 5.days.since.to_s, fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "Video Lessons", second_name: "Video Lessons on Agile", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 6.days.since.to_s, fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "Got Node?", second_name: "Got Node? AWS Latest Cloud to Offer Node.js", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 7.days.since.to_s, fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "MongoDB", second_name: "MongoDB Gets Better Security", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 8.days.since.to_s, fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "Business Process", second_name: "Business Process", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), ending: 9.days.since.to_s, fine_print: %Q(#{"This is the fine print" * 100})},
]

Manager.all.each do |manager|
  special_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = SpecialMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
  end
end

coupon_messages = [
    {name: "QCon New York", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), second_name: "QCon New York Update", type_of_discount: "percentage_off", discount_amount: '10', coupon_code: '1234asdf', fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "Google Promises", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), second_name: "Google Promises Not to Sue for Using Their Pledged Patents", type_of_discount: "dollar_off", discount_amount: '10', fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "GCC 4.8 Completes", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), second_name: "GCC 4.8 Completes Move to C++", type_of_discount: "percentage_off", discount_amount: '20', coupon_code: '1234asdf', fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "EclipseCon 2013", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), second_name: "EclipseCon 2013 Roundup", type_of_discount: "dollar_off", discount_amount: '30', coupon_code: 'asdf', fine_print: %Q(#{"This is the fine print" * 100})},
    {name: "Release Cadence", content: %Q(#{"This is the first paragraph"  * 100}\n\n#{"This is the second paragraph" * 100}), second_name: "Release Cadence Report - Survey Launched", type_of_discount: "percentage_off", discount_amount: '10', fine_print: %Q(#{"This is the fine print" * 100})},
]

Manager.all.each do |manager|
  coupon_messages.each do |message_attrs|
    shop = manager.shop
    inactive_label = shop.inactive_label
    message = CouponMessage.new(message_attrs)
    message.manager_id = manager.id
    message.label_ids = [inactive_label.id]
    message.save_draft
  end
end