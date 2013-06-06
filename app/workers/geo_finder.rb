class GeoFinder
	@queue = :latlngqueue
	def self.perform(location_id)
		TrackLatLng.fetch_lat_lng(location_id)
	end
end