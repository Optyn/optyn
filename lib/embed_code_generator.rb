class EmbedCodeGenerator
	def self.generate_embed_code(app)
		%Q(
				<div id="optyn-container">
					<h4>Welcome to Optyn</h4>
					<script>
					try{
						jQuery();
					}catch(e){
						
						var js = document.createElement("script");

						js.type = "text/javascript";
						js.src = "//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js";

						document.body.appendChild(js);

					}
					</script>
					<script src="#{SiteConfig.app_base_url}/api/shop/button_framework.js?app_id=#{app.uid}"></script>
				</div>
				<iframe name='optyn-iframe' id="optyn-iframe" style='display:none'></iframe>
			)
	end
end