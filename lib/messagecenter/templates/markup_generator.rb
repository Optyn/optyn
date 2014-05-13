module Messagecenter
  module Templates
    class MarkupGenerator
      include ActionView::Helpers::TagHelper
      include ERB::Util
      include ActionView::Helpers::OutputSafetyHelper
      include Merchants::MessagesHelper
      attr_accessor :template

      CONTENT_COMPONENT_TYPE = "content"
      INTRODUCTION_COMPONENT_TYPE = "introduction"

      def self.generate_editable_content(message, template)
        markup = ""
        content = message.content
        if content.blank?
          blank_template = BlankTemplate.new(template: template, message: message, editable: 'true')
          markup = blank_template.build_markup
        else
          existing_template = ExistingTemplate.new(template: template, message: message, editable: 'true')
          markup = existing_template.build_markup
        end  

        markup
      end

      def self.generate_content(message, template)
        markup = ""
        content = message.content
        if content.blank?
          blank_template = BlankTemplate.new(template: template, message: message, editable: 'false')
          markup = blank_template.build_markup
        else
          parsed_content = JSON.parse(content)
          existing_template = ExistingTemplate.new(template: template, message: message, editable: 'false')
          markup = existing_template.build_markup
        end  

        markup
      end

      def add_toolset_to_components(data_model)
        components_hash = data_model.clone
        toolset_markup = static_toolset_markup(components_hash)
        type = components_hash.delete('type')
        components_hash.each_pair do |component_name, compoenent_content|          
          components_hash[component_name] = toolset_markup + compoenent_content['content']
        end

        components_hash.to_json
      end


      def build_social_sharing_options(component,container_template)
        if component.has_key? :social_sharing
          social_sharing = component.social_sharing
                    
          if social_sharing.has_key? :fb_sharing
            facebook = social_sharing.fb_sharing
            fb_html = if facebook.html.present? 
                        "<span class='optyn-fbshare'><a href = #{get_social_share_link('facebook', @message, facebook.url)} style= 'color: #111;text-shadow: 1px 1px 1px #eee;height: 20px;text-decoration:none;font-size:12px;line-height:20px;display:inline-block;' target ='_blank'> #{facebook.html}
                        &nbsp; </a></span>" 
                      else
                        get_default_html("facebook")
                      end
            container_template = container_template.sub(Template::FB_PLACE_HOLDER_ELEM, fb_html)
          end

          #twitter
          if component.social_sharing.has_key? :twitter_sharing
            twitter = social_sharing.twitter_sharing
            twitter_html = if twitter.html.present?
                            "<span class='optyn-twittershare'><a href = #{get_social_share_link('twitter', @message, twitter.url)} style= 'color: #111;text-shadow: 1px 1px 1px #eee;height: 20px;text-decoration:none;font-size:12px;line-height:20px;display:inline-block;' target ='_blank'> #{twitter.html}
                            </a></span>"
                          else
                            get_default_html("twitter")
                          end
            container_template = container_template.sub(Template::TW_PLACE_HOLDER_ELEM, twitter_html)
          end
        end
        container_template
      end

      def static_toolset_markup(grid_data_model, only_add = false)
        static_content = ""
        data_model = grid_data_model.clone

        
        if CONTENT_COMPONENT_TYPE == data_model['type']
          
          dropdown_links  = ""
          type = data_model.delete('type')
          data_model.each_pair do |key, val|
            dropdown_links += '<li>' + '<a class="add-section-link" href="#"' + ' data-section-type= ' + '"' + key + '"' + '>' + '&nbsp;&nbsp;' + val['title'] + '&nbsp;</a>' + '</li>'
          end

          static_content = <<-HTML
                <div class="row template-section-toolset #{ "no-divisions-toolset" if only_add}">
                  <div class="btn-group pull-right">
                    #{
                      %{
                        <button class="btn ink-action-edit">
                          <i class="icon-edit icon-white"></i>
                        </button>
                        <button class="btn ink-action-move handle">
                          <i class="icon-fullscreen icon-white"></i>
                        </button>
                        <button class="btn ink-action-delete">
                          <i class="icon-trash icon-white action-delete"></i>
                        </button>
                      } unless only_add
                    }
                    <a class="btn dropdown-toggle" data-toggle="dropdown" href="#"><i class="icon-plus icon-white">&nbsp;<span class="caret"></span></i></a>
                    <ul class="dropdown-menu">
                      #{dropdown_links}
                    </ul>
                  </div>
                </div>
              HTML

        elsif INTRODUCTION_COMPONENT_TYPE == data_model['type']
          static_content = <<-HTML
            <div class="row template-section-toolset">
              <div class="btn-group pull-right">
                <button class="btn ink-action-edit">
                <i class="icon-edit icon-white"></i>
                </button>
              </div>
            </div>
          HTML
        else
          ""
        end

        static_content   
      end

      def self.add_component_class(component, component_parent)
        node = add_node_if_none(component)  

        optyn_class = ["optyn-#{component_parent}"]
        optyn_class << "optyn-#{component['type']}" if "grid" == component.name || "container" == component.name

        if node['class'].present? 
          class_str = optyn_class.join(" ")
          node['class'] = node['class'] +  " " + class_str unless node['class'].include?(class_str)
        else
          node['class'] = optyn_class.join(" ")
        end

      end

      def self.add_data_type_to_component(component)

        node = add_node_if_none(component)
      
        node['data-type'] = component['type']
        
      end

      def self.add_image_placeholder_container(image_component)
        if image_component.search('img').present?
          image_component.search('img').wrap("<div></div>")
          node = image_component.search('div').first()
          img_node = image_component.search('img').first()
          
          node['style'] = image_component['style'] if image_component.attributes.has_key?('style')
          
          img_node.attributes.each_pair do |key, val|
            if 'src' != key
              node[key] = img_node[key]
            else
              node['data-src-placeholder'] = img_node['src']
            end
          end
        end
      end

      private
        def self.add_node_if_none(component)
          node = nil
          if component.child.present? && component.child.element?
            node = component.child
          else
            node = component.add_child("<span></span>")
          end
          node
        end

    end #end of the MarkupGenerator class
  end #end of templates module.
end #end of messagecenter module