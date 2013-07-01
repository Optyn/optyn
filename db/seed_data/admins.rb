#Admin Users

#super_admin
puts 'Setting up default super_admin'
admin = Admin.create!(
    :email => 'super_admin@optyn.com',
    :password => "admin_super",
    :password_confirmation => "admin_super",
    :role => "super_admin"
)
puts 'New super_admin created: ' << admin.email

#admin
puts 'Setting up default admin'
admin = Admin.create!(
    :email => 'admin@optyn.com',
    :password => "admin_super",
    :password_confirmation => "admin_super",
    :role => "admin"
)
puts 'New admin created: ' << admin.email