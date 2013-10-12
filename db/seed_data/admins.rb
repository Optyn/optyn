#admin
puts 'Setting up default admin'
admin = Admin.create!(
    :email => 'admin@optyn.com',
    :password => "admin_super",
    :password_confirmation => "admin_super",
)
puts 'New admin created: ' << admin.email