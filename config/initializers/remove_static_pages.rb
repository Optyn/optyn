class Engine < Rails::Engine
	unless "development" == Rails.env
		initializer "remove assets directories from pipeline" do |app|
			app.config.assets.paths = app.config.assets.paths - app.config.assets.paths.grep(/back_end_static_page.*|front_end_static_page.*/)
		end
	end
end