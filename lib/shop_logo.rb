module ShopLogo
  def email_body_message_logo(shop,message_uuid, template_uuid, choice, logo_text)
    message = Message.for_uuid(message_uuid)
    template = Template.for_uuid(template_uuid)
    template.update_attributes(logo: choice)

    case template.logo
    when "image"
      if template.image_location.present?
        content = <<-HTML
          <a here="#{template.image_location}" href="#{message.message_url(shop)}" target="_blank">
            <img src="#{template.image_location}" title="#{shop.name.gsub(/['"]/, "")}" style="max-width:580px;" />
          </a>
        HTML
        content.to_s.html_safe
      else
        %{<img src="http://placehold.it/580x100" title="#{shop.name.gsub(/['"]/, "")}", style="max-height:250px;max-width:580px;" class="nl-width-580" />}.html_safe
      end
    when "text"
      template.update_attributes(title: logo_text)
      %{<h3>#{template.title.to_s}</h3>}.html_safe
    else
      %{<img src="http://placehold.it/580x100" title="#{shop.name.gsub(/['"]/, "")}", style="max-height:180px;max-width:580px;" class="nl-width-580" />}.html_safe
    end

  end

  def email_body_shop_logo(shop)
    if shop.has_logo?
      if shop.website.present?
        content = <<-HTML
          <a here="#{shop.logo_location}" href="#{shop.website}" target="_blank">
            <img src="#{shop.logo_location}" title="#{shop.name.gsub(/['"]/, "")}" style="max-width:580px;" />
          </a>
        HTML
        content.to_s.html_safe
      else
        %{<img src="#{shop.logo_location}" title="#{shop.name.gsub(/['"]/, "")}", style="max-height:250px;max-width:580px;" class="nl-width-580" />}.html_safe
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
