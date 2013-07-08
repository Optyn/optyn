class EmbedCodeGenerator
	def self.generate_embed_code(app)
    %Q(
      <script type="text/javascript" src="#{SiteConfig.app_base_url}/api/shop/button_script.js?app_id=#{app.uid}"></script>
    )
	end
end
