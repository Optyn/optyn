class FileImport
	@queue = :importuserqueue	
	def self.perform(file,shop_id)
		shop=Shop.find(shop_id)
		User.import(file, shop)
	end
end