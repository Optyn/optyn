namespace :geo do
  desc "fetch latitude and longitude for all addresses"
  task :fetch_location => :environment do |t|  
    Location.all.each do |loc|
      TrackLatLng.fetch_lat_lng(loc.id)
    end
  end
end