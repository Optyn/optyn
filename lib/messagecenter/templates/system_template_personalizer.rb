require 'haml'
require 'sass'

module Messagecenter
  module Templates
    module SystemTemplatePersonalizer
      class Sass::Tree::RuleNode
        def set_property(property, value)
          prop = self.children.find{|child| child.class.name == 'Sass::Tree::PropNode' && child.instance_variable_get(:@resolved_name) == property }
          if prop.blank?
            prop = self.children.first.clone
            prop.instance_variable_set(:@resolved_name, property)
            self << prop
          end
          prop.instance_variable_set(:@resolved_value, value)
        end
      end


      def default_selectable_properties(current_shop)
        {
          properties:{
            layout: {
              css: {
                :"background-color" => Template::LAYOUT_BACKGROUND_COLOR
              }
            },

            header: {
              css: {
                :'background-color' => current_shop.header_background_color
              },
              
              headline: {
                css: {
                  :"font-family" => Template::HEADER_FONT_FAMILIES
                }  
              }
            },

            content:{
              css: {
                :'background-color' => Template::CONTENT_BACKGROUND_COLOR,
              }, 

              headline: {
                css: {
                  color: Template::CONTENT_TITLE_COLOR
                }  
              },

              paragraph: {
                css: {
                  color: Template::CONTENT_PARAGRAPH_COLOR
                }
              },

              link: {
                css: {
                  color: Template::CONTENT_LINK_COLOR
                }
              }
            },
            sidebar:{
              css: {
                :'background-color' => Template::SIDEBAR_BACKGROUND_COLOR,
              }, 

              headline: {
                css: {
                  color: Template::CONTENT_TITLE_COLOR
                }  
              },

              paragraph: {
                css: {
                  color: Template::CONTENT_PARAGRAPH_COLOR
                }
              },

              link: {
                css: {
                  color: Template::CONTENT_LINK_COLOR
                }
              }
            },
            rightSidebar:{
              css: {
                :'background-color' => Template::SIDEBAR_BACKGROUND_COLOR,
              }, 

              headline: {
                css: {
                  color: Template::CONTENT_TITLE_COLOR
                }  
              },

              paragraph: {
                css: {
                  color: Template::CONTENT_PARAGRAPH_COLOR
                }
              },

              link: {
                css: {
                  color: Template::CONTENT_LINK_COLOR
                }
              }
            },
            leftSidebar:{
              css: {
                :'background-color' => Template::SIDEBAR_BACKGROUND_COLOR,
              }, 

              headline: {
                css: {
                  color: Template::CONTENT_TITLE_COLOR
                }  
              },

              paragraph: {
                css: {
                  color: Template::CONTENT_PARAGRAPH_COLOR
                }
              },

              link: {
                css: {
                  color: Template::CONTENT_LINK_COLOR
                }
              }
            }
          }
        }
      end

      def replace_custom_tags
         #get the containers optyn classes
        @parsed_html.css('container').each do |container_child|
          container_child.swap(container_child.children.to_s)
        end

        #get the row optyn classes
        @parsed_html.css('row').each do |row_child|
          row_child.swap(row_child.children.to_s)
        end

        #get the grid optyn classes
        @parsed_html.css('grid').each do |grid_child|
          grid_child.swap(grid_child.children.to_s)
        end    

        #get the division optyn classes
        @parsed_html.css('division').each do |division_child|
          division_child.swap(division_child.children.to_s)
        end

        #get the headline optyn classes
        @parsed_html.css('headline').each do |headline_child|
          headline_child.swap(headline_child.children.to_s)
        end

        #get the paragraph optyn classes
        @parsed_html.css('paragraph').each do |paragraph_child|
          paragraph_child.swap(paragraph_child.children.to_s)
        end

        @parsed_html.css('image').each do |image_child|
          Messagecenter::Templates::MarkupGenerator.add_image_placeholder_container(image_child)
          Messagecenter::Templates::MarkupGenerator.add_component_class(image_child, 'replaceable-image')  
          image_child.swap(image_child.children.to_s)
        end

        self.html = @parsed_html.to_s
      end

      def add_markup_classes
        set_parsed_html
        #get the containers optyn classes
        @parsed_html.css('container').each do |container_child|
          Messagecenter::Templates::MarkupGenerator.add_component_class(container_child, 'container')
        end


        #get the row optyn classes
        @parsed_html.css('row').each do |row_child|
          Messagecenter::Templates::MarkupGenerator.add_component_class(row_child, 'row')    
        end

        #get the grid optyn classes
        @parsed_html.css('grid').each do |grid_child|
          Messagecenter::Templates::MarkupGenerator.add_component_class(grid_child, 'grid')
        end    

        #get the division optyn classes
        @parsed_html.css('division').each do |division_child|
          Messagecenter::Templates::MarkupGenerator.add_component_class(division_child, 'division')
        end

        #get the headline optyn classes
        @parsed_html.css('headline').each do |headline_child|
          Messagecenter::Templates::MarkupGenerator.add_component_class(headline_child, 'headline') 
        end

        #get the paragraph optyn classes
        @parsed_html.css('paragraph').each do |paragraph_child|
          Messagecenter::Templates::MarkupGenerator.add_component_class(paragraph_child, 'paragraph') 
        end

        @parsed_html.css('fbshare').each do |paragraph_child|
          Messagecenter::Templates::MarkupGenerator.add_component_class(paragraph_child, 'fbshare') 
        end

        @parsed_html.css('twittershare').each do |paragraph_child|
          Messagecenter::Templates::MarkupGenerator.add_component_class(paragraph_child, 'twittershare') 
        end

        # Messagecenter::Templates::MarkupGenerator.add_component_class(image_child, 'replaceable-image')  

        self.html = @parsed_html.to_s        
      end

      def convert_system_template(selectable_properties)
        set_parsed_html
        set_styles
        parse_css
        convert_layout((selectable_properties[:properties][:layout] rescue {}))
        convert_header((selectable_properties[:properties][:header] rescue {}))
        convert_content((selectable_properties[:properties][:content] rescue {}))
        sidebar_properties = selectable_properties[:properties][:sidebar]
        left_sidebar_properties = selectable_properties[:properties][:leftSidebar]
        right_sidebar_properties = selectable_properties[:properties][:rightSidebar]
        convert_sidebar((selectable_properties[:properties][:sidebar] rescue {}), ".sidebar-container .optyn-sidebar") if sidebar_properties.present?
        convert_sidebar((selectable_properties[:properties][:leftSidebar] rescue {}), ".left-sidebar .optyn-sidebar") if left_sidebar_properties.present?
        convert_sidebar((selectable_properties[:properties][:rightSidebar] rescue {}), ".right-sidebar .optyn-sidebar") if right_sidebar_properties.present?
        convert_footer
        replace_styles
        self.html = @parsed_html.to_s
      end

      private
        def convert_layout(layout_properties)
          if layout_properties[:css].present?
            #modified stylesheet to add the background color
            node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == "table.body"}
            if node.present?
              layout_properties[:css].each_pair do |css_key, css_value|
                node.set_property(css_key.to_s, css_value)
              end
            end
          end

          #TODO Check for social media links
        end

        def convert_header(header_properties)
          shop = self.shop

          if header_properties[:css].present?
            #replace the background color
            node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-introduction"}
            if node.present?
              header_properties[:css].each_pair do |css_key, css_value|
                node.set_property(css_key.to_s, css_value)
              end
            end

            if header_properties[:headline].present? && header_properties[:headline][:css].present?
              node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-introduction .optyn-headline"}
              if node.present?
                header_properties[:headline][:css].each_pair do |css_key, css_value|
                  node.set_property(css_key.to_s, css_value)
                end
              end
            end
          end

          if header_properties['twitter'].present?
            css_style = header_properties['twitter']['show'] == "0" ? "display:none" : "display:block"
            tw_style = @parsed_html.css(".optyn-twittershare").first.attribute('style').value
            @parsed_html.css(".optyn-twittershare").first.attribute('style').value = tw_style + css_style
          end

          if ((@parsed_html.css("fbshare").size()>0) || (@parsed_html.css("twittershare").size()>0) ) && header_properties['shareurl'].present?
            @parsed_html.css("twittershare").first.attribute('shareurl').value = header_properties['shareurl']
            @parsed_html.css("fbshare").first.attribute('shareurl').value = header_properties['shareurl']
            @parsed_html.css("twittershare").first.attribute('text').value = header_properties['text']
          end

          if header_properties['facebook'].present?
            css_style = header_properties['facebook']['show'] == "0" ? "display:none" : "display:block"
            tw_style = @parsed_html.css(".optyn-fbshare").first.attribute('style').value
            @parsed_html.css(".optyn-fbshare").first.attribute('style').value = tw_style + css_style
          end
          
          #replace the palceholder image tag with shop image or name based om if a shop has a logo
          if header_properties['logo'].present? 
            introduction_division = @parsed_html.css('container[type=introduction]').first.css('division[type=introduction]').first
            introduction_division.css('img').each do |image|
              msg_logo = email_body_message_logo(shop,header_properties['message_uuid'],header_properties['template_uuid'],header_properties['logo'],header_properties['logo_text'])
              msg_logo_node = Nokogiri::HTML::fragment(msg_logo)
            
              if msg_logo_node.css('img').present?
                image_node = msg_logo_node.css('img').first
                style_attr = image_node['style']
                image_node['style'] = style_attr.present? ? "#{style_attr} margin:auto; float:none; display:inline;" :  "margin:auto;float:none;display:inline;"
                image_node.swap(%{<image>#{image_node.to_s}</image>})
                image.swap(%{<span class="center">#{msg_logo_node.children.to_s}</span>})
              else
                header_node = msg_logo_node.css('h3').first
                class_attr = header_node['class']
                header_node['class'] = class_attr.present? ? "#{class_attr} center" : "center"
                header_node.swap("<headline>#{header_node.to_s}</headline>")
                image.swap(%{#{msg_logo_node.children.to_s}})
              end
            end
          end
          @parsed_html.css('headline').each do |headline_child|
            Messagecenter::Templates::MarkupGenerator.add_component_class(headline_child, 'headline') 
          end
        end
        
        def convert_content(content_properties)
          if content_properties[:css].present?
            #change the background color of the core content
            node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-content"}
            if node.present?
              node.set_property('background-color', content_properties[:css][:'background-color'])
            end
          end

          if content_properties[:headline].present?
            #change the css properties of the headline
            node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-content .optyn-headline"}
            if node.present?
              headline_style_properties = content_properties[:headline][:css]
              headline_style_properties.each_pair do |css_key, css_value|
                node.set_property(css_key.to_s, css_value)          
              end
            end
          end

          if content_properties[:paragraph].present?
            #change the css properties of the paragraph
            node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-content .optyn-paragraph"}
            if node.present?
              paragraph_style_properties = content_properties[:paragraph][:css]
              paragraph_style_properties.each_pair do |css_key, css_value|
                node.set_property(css_key.to_s, css_value)          
              end
            end
          end

          if content_properties[:link].present?
            #change the css properties of links
            node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-content .optyn-link"}
            if node.present?
              paragraph_style_properties = content_properties[:link][:css]
              paragraph_style_properties.each_pair do |css_key, css_value|
                node.set_property(css_key.to_s, css_value)          
              end             
            end
          end       

          #change the background color of the sidebar
          #node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-sidebar"}
          #node.set_property('background-color', '#C9C9C9')
        end

        def convert_sidebar(sidebar_properties, sidebar_classname)
          background_class = sidebar_classname.split(/\s/).first
          if sidebar_properties[:css].present?
            #change the background color of the core content
            node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-content #{background_class}"}
            puts node
            if node.present?
              node.set_property('background-color', sidebar_properties[:css][:'background-color'])
            end
          end

          if sidebar_properties[:headline].present?
            #change the css properties of the headline
            node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-content #{sidebar_classname} .optyn-headline"}
            if node.present?
              headline_style_properties = sidebar_properties[:headline][:css]
              headline_style_properties.each_pair do |css_key, css_value|
                node.set_property(css_key.to_s, css_value)          
              end
            end
          end

          if sidebar_properties[:paragraph].present?
            #change the css properties of the paragraph
            node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-content #{sidebar_classname} .optyn-paragraph"}
            if node.present?
              paragraph_style_properties = sidebar_properties[:paragraph][:css]
              paragraph_style_properties.each_pair do |css_key, css_value|
                node.set_property(css_key.to_s, css_value)          
              end
            end
          end

          if sidebar_properties[:link].present?
            #change the css properties of links
            node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-content #{sidebar_classname} .optyn-link"}
            if node.present?
              paragraph_style_properties = sidebar_properties[:link][:css]
              paragraph_style_properties.each_pair do |css_key, css_value|
                node.set_property(css_key.to_s, css_value)          
              end             
            end
          end       

          #change the background color of the sidebar
          # node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-sidebar"}
          # node.set_property('background-color', '#C9C9C9')
        end


        def convert_footer
          #change the permission
          footer_node = @parsed_html.css('container[type=footer]').first.css('division[type=footer]').first
          permission_node = footer_node.css('permission').first
          shop_name_node = permission_node.css('shop-name').first
          shop_name_node.swap(shop.name)
          permission_node.swap(permission_node.children.to_s)

          #change the address node with shops address
          address_node = footer_node.css('address').first
          begin
            address_node.swap(shop.message_address)
          rescue
            address_node.swap(address_node.children.to_s)
          end
        end

        def set_styles
          styles = ""
          @parsed_html.css('style').each do |style|
            styles << style.children.to_s
          end
          @styles  = styles
        end

        def set_parsed_html
          @parsed_html = Nokogiri::HTML(self.html)
        end

        def parse_css()
          engine = Sass::Engine.new(@styles, :syntax => :scss)
          tree = engine.to_tree
          Sass::Tree::Visitors::CheckNesting.visit(tree)
          result = Sass::Tree::Visitors::Perform.visit(tree)
          Sass::Tree::Visitors::CheckNesting.visit(result)
          result, extends = Sass::Tree::Visitors::Cssize.visit(result)
          Sass::Tree::Visitors::Extend.visit(result, extends)

          @parsed_result = result
          @parsed_extends = extends
        end

        def replace_styles()
          #replace the styles tag
          header = @parsed_html.css('style').first.parent
          @parsed_html.css('style').remove
          header.add_child(%{<style type="text/css">#{@parsed_result.to_s}</style>})
        end
    end #end of the SystemTemplateParser module
  end #end of the Templates module
end #end of the Messagecenter module