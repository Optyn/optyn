module ShopsHelper
	def business_type(shop)
    if shop.stype == 'local'
      "Local"
    else
      shop.stype == 'online'
      "Website"
    end
	end
end
