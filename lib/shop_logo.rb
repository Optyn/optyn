module ShopLogo
  def email_body_shop_logo(shop)
    if shop.has_logo?
      if shop.website.present?
        content = <<-HTML
          <a here="#{shop.logo_location}" href="#{shop.website}" target="_blank">
            <img src="#{shop.logo_location}" title="#{shop.name}" style="margin:5px;" />
          </a>
        HTML
        content.to_s.html_safe
      else
        %{<img src="#{shop.logo_location}" title="#{shop.name}", style="margin:5px;max-height:150px; max-width:100%;" />}.html_safe
      end
    else
      if shop.website.present?
        content = <<-HTML
          <a href="#{shop.website}" target="_blank" style="color: white; font-weight: bold; text-decoration: none;">
            <h3>#{shop.name}</h3>
          </a>
        HTML
        content.to_s.html_safe
      else
        %{<h3>#{shop.name}</h3>}.html_safe
      end 
    end
  end
end