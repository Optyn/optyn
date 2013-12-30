class GeoFinder
  include Sidekiq::Worker
  
	@queue = :general_queue
	def perform(location_id)
		TrackLatLng.fetch_lat_lng(location_id)
	end
end