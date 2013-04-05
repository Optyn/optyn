module TrackLatLng
	def self.fetch_lat_lng(location_id)
		location = Location.find(location_id)
		geo_coder = Geocoder.search(:postal_code=>location.zip)[0]
		if geo_coder.present?
			location.latitude = geo_coder.latitude
			location.longitude = geo_coder.longitude
			location.save
		end
	end
end