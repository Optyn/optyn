class ImportCsvUser
	@queue = :importuserqueue	
	def self.perform(file,shop_id,manager_id)
		shop=Shop.find(shop_id)
		manager=Manager.find(manager_id)
		User.import(file, shop, manager)
	end
end