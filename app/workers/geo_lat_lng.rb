class GeoLatLng
	@queue = :latlngqueue
	def self.perform(location_id)
		location = Location.find(location_id)
		geo_coder = Geocoder.search(:postal_code=>location.zip)[0]
		location.latitude = geo_coder.latitude
		location.longitude = geo_coder.longitude
		location.save
	end
end