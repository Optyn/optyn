namespace :connections do
  desc "Unsubscribe user from list."
  task :unsubcribes  => :environment do
    filepath = ENV["filepath"]
    manager = Manager.find_by_email(ENV["manager_email"])
    if !manager.blank?
      shop = manager.shop
      if filepath.present?
        csv_table = CSV.table(filepath, {headers: true})
        headers = csv_table.headers
        puts headers
        csv_table.each do |row|
          user = User.find_by_email(row[:unsubscribed])
          if !user.blank?
            connection = Connection.find_by_user_id_and_shop_id(user.id, shop.id)
            connection.make_inactive
            puts user.email
          else
            puts "invalid email address #{row[:unsubscribed]}"
          end
        end
      else
        puts "Invalid file #{ENV["filepath"]}."
      end
    else
      puts "Invalid manager email #{ENV["manager_email"]}."
    end
  end
end