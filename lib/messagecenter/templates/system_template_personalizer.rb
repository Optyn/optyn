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

      def personalize
        set_parsed_html
        set_styles
        parse_css
        personalize_layout
        personalize_header
        personalize_content
        personalize_footer
        replace_styles
        self.html = @parsed_html.to_s
      end

      private
        def personalize_layout
          #modified stylesheet to add the background color
          node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == "table.body"}
          node.set_property('background-color', '#EEEEEE')

          #TODO Check for social media links
        end

        def personalize_header
          shop = self.shop

          #replace the background color
          node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-introduction"}
          node.set_property('background-color', shop.header_background_color)

          #replace the palceholder image tag with shop image or name based om if a shop has a logo
          introduction_division = @parsed_html.css('container[type=introduction]').first.css('division[type=introduction]').first
          introduction_division.css('img').each do |image|
            shop_logo = email_body_shop_logo(shop)
            shop_logo_node = Nokogiri::XML(shop_logo)
            if shop_logo_node.css('img').present?
              image.swap(%{<span class="optyn-replaceable-image">#{shop_logo}</span>})
            else
              image.swap(%{<h2><span class="optyn-headline">#{shop_logo}</span></h2>})
            end
          end
        end  

        def personalize_content
          #change the background color of the core content
          node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-content"}
          node.set_property('background-color', '#FFFFFF')

          #change the background color of the sidebar
          node = @parsed_result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-sidebar"}
          node.set_property('background-color', '#C0C0C0')
        end

        def personalize_footer
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