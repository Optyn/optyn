class GeoFinder
	@queue = :general_queue
	def self.perform(location_id)
		TrackLatLng.fetch_lat_lng(location_id)
	end
end