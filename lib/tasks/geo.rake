namespace :geo do
  desc "fetch latitude and longitude for all addresses"
  task :fetch_location => :environment do 
   puts "Geo location called #{Time.now}"  
   Location.all.each do |loc|
    	puts "Running for #{loc.inspect}"
      TrackLatLng.fetch_lat_lng(loc.id)
      #Rails.logger.debug("Hello World #{Time.now}")
   end 
  end
end
