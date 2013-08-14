namespace :beta_users do
	desc "Go through the emails and send emails to beta registers"
	task :send_email => :environment do
		filepath = ENV['filepath']
		unless filepath.blank?
			csv_table = CSV.table(filepath, {headers: true})
			headers = csv_table.headers
			counter = 0
			csv_table.each do |row|
				puts "Email being sent to: #{row[:email]}"
				BetaUserMailer.send_invite(row[:email]).deliver
				counter += 1

				if counter >= 5
					puts "Sleeping for a second..."
					counter = 0
					sleep(1.0)
				end
			end
		end
	end
end 