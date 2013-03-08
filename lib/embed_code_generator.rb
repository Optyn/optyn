class EmbedCodeGenerator
	def self.generate_embed_code(shop)
		%Q(
				<div id="optyn-container">
					<h4>Welcome to Optyn</h4>
					<script src="#{SiteConfig.app_base_url}/api/shop/button_framework.js?app_id=#{shop.app_id}" /></script>
				</div>
				<iframe name='optyn-iframe' id="optyn-iframe" style='display:none'></iframe>
			)
	end
end