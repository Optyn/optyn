module ShopLogo
  def email_body_message_logo(shop, choice, logo_text, image_location=nil, headerlink=nil)
    logo_content = template_logo_choice(shop, choice, logo_text, image_location)

    if headerlink.present?
      content = <<-HTML
         <a here="#{image_location}" href="#{headerlink}" target="_blank">
          #{logo_content}
         </a>
      HTML
    end

    content.present? ? content : logo_content
  end

  def template_logo_choice(shop, choice, logo_text, image_location=nil)
    case choice
    when "image"
      if image_location.present?
        content = <<-HTML
          <img src="#{image_location}" title="#{shop.name.gsub(/['"]/, "")}" style="max-width:580px;" />
        HTML
        content.to_s.html_safe
      else
        %{<img src="http://placehold.it/580x100" title="#{shop.name.gsub(/['"]/, "")}", style="max-height:250px;max-width:580px;" />}.html_safe
      end
    when "text"
      %{<h3>#{logo_text.to_s}</h3>}.html_safe
    else
      %{<img src="http://placehold.it/580x100" title="#{shop.name.gsub(/['"]/, "")}", style="max-height:250px;max-width:580px;" />}.html_safe
    end
  end

  def email_body_shop_logo(shop)
    if shop.has_logo?
      if shop.website.present?

        content = <<-HTML
          <a here="#{shop.logo_location}" href="#{shop.display_website}" target="_blank">
            <img src="#{shop.logo_location}" title="#{shop.name.gsub(/['"]/, "")}" style="max-width:580px;" />
          </a>
        HTML
        content.to_s.html_safe
      else
        %{<img src="#{shop.logo_location}" title="#{shop.name.gsub(/['"]/, "")}", style="max-height:250px;max-width:580px;" />}.html_safe
      end
    else
      if shop.website.present?
        content = <<-HTML
          <a href="#{shop.display_website}" target="_blank" style="color: white; font-weight: bold; text-decoration: none;">
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
