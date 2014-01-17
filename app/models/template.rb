require 'nokogiri'
require 'messagecenter/templates/markup_generator'
require 'messagecenter/templates/existing_template'
require 'messagecenter/templates/blank_template'
require 'haml'
require 'sass'

class Template < ActiveRecord::Base

  attr_accessor :parsed_html

  attr_accessible :shop_id, :system_generated, :name, :structure, :html

  serialize :structure, Hash

  has_many :messages
  has_many :stylesheets
  belongs_to :shop

  after_create :create_structure

  scope :fetch_system_generated, where(system_generated: true)

  scope :for_shop, ->(shop_identifier) { where(shop_id: shop_identifier) }

  scope :for_name, ->(template_name) { where(name: template_name) }

  PLACE_HOLDER_ELEM = "<placeholder></placeholder>\n"

  def self.system_generated 
    fetch_system_generated
  end

  def self.basic
    for_name("Basic").first
  end

  def self.copy(template_id, shop)
    existing_template = Template.find(template_id)
    new_template = Template.new(html: existing_template.html, name: "#{shop.name} #{existing_template.name}", shop_id: shop.id)
    new_template.personalize
    new_template.save
  end

  def fetch_content(message_content)
    content = ""
    
    content = Messagecenter::Templates::MarkupGenerator.generate(message_content, self)
    
    content
  end

  def personalize
    @parsed_html = Nokogiri::HTML(self.html)
    personalize_layout
    personalize_header
    personalize_content
    personalize_footer
    self.html = @parsed_html.to_s
  end

  private
    def create_structure
      content = Nokogiri::HTML(self.html)
      #start traversing the hierarchy goes as:
      #containers => rows => grids => divisions => editable content
      wrapper = HashWithIndifferentAccess.new(containers: [], html: "")

      containers = wrapper[:containers]
      content.css('container').each do |container_child|
        
        rows = []
        container_child.css('row').each do |row_child|

          grids = []
          row_child.css('grid').each do |grid_child|
            divisions = []
            data_model = build_data_model(grid_child.css('division'))

            grid_child.css('division').each do |division_child|
              sanitize_division(division_child)
              divisions << HashWithIndifferentAccess.new(html: division_child.children.to_s, type: division_child['type'])
              Messagecenter::Templates::MarkupGenerator.add_component_class(division_child, 'division')
              division_child.parent.add_child(add_newline(PLACE_HOLDER_ELEM)) unless division_child.parent.to_s.include?(PLACE_HOLDER_ELEM)
              
              division_child.remove
            end

            grid = HashWithIndifferentAccess.new(divisions: divisions, data_model: data_model)
            grid_parent = grid_child.parent
            grid_child.swap(add_newline(PLACE_HOLDER_ELEM))
            # grid_parent.add_child(PLACE_HOLDER_ELEM) unless row_child.to_s.include?(PLACE_HOLDER_ELEM)
            
            Messagecenter::Templates::MarkupGenerator.add_component_class(grid_child, 'grid')
            grid[:html] = grid_child.children.to_s
            
            grids << grid
          end


          row = HashWithIndifferentAccess.new(grids: grids)
          row_parent = row_child.parent
          row_child.swap(add_newline(PLACE_HOLDER_ELEM))
          # row_parent.add_child(PLACE_HOLDER_ELEM) unless _child.to_s.include?(PLACE_HOLDER_ELEM)

          Messagecenter::Templates::MarkupGenerator.add_component_class(row_child, 'row')
          row[:html] = row_child.children.to_s
          
          rows << row
        end

        container = HashWithIndifferentAccess.new(rows: rows, type: container_child['type'])
        container_parent = container_child.parent
        container_child.swap(add_newline(PLACE_HOLDER_ELEM))
        # container_parent.add_child(PLACE_HOLDER_ELEM) unless container_parent.parent.to_s.include?(PLACE_HOLDER_ELEM)

        Messagecenter::Templates::MarkupGenerator.add_component_class(container_child, 'container')
        container[:html] = container_child.children.to_s
        
        containers << container
        
      end

      wrapper[:html] = content.to_s

      self.structure = wrapper
      self.save

    end

    #Replace the <headline>, <paragraph>, <image>
    def sanitize_division(division_child)
      division_child.css('headline').each do |headline_child|
        Messagecenter::Templates::MarkupGenerator.add_component_class(headline_child, 'headline')  
        headline_html = headline_child.children.to_s
        headline_child.swap(headline_html)
      end

      division_child.css('paragraph').each do |paragraph_child|
        Messagecenter::Templates::MarkupGenerator.add_component_class(paragraph_child, 'paragraph')  
        paragraph_html = paragraph_child.children.to_s
        paragraph_child.swap(paragraph_html)
      end

      #Add for image
    end

    #build the data model when parsing the divisions for each row => grid when building the structure
    def build_data_model(divisions)
      data_model = {}

      divisions.each do |division|
        data_model[division['type']] = {}
        div_hash = data_model[division['type']]
        div_hash['title'] = division['type'].to_s.humanize
        sanitize_division(division)
        div_hash['content'] = division.children.to_s.squish
      end

      data_model
    end

    def add_newline(html)
      "\n" + html + "\n"
    end

    def personalize_layout
      #modified stylesheet to add the background color
      styles = fetch_styles
      result, extends = parse_css(styles)
      node = result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == "table.body"}
      node.set_property('background-color', '#EEEEEE')
      styles = result.to_s
      replace_styles(styles)

      #TODO Check for social media links
    end

    def personalize_header
      shop = self.shop

      #replace the background color
      styles = fetch_styles
      result, extends = parse_css(styles)
      node = result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-header"}
      node.set_property('background-color', shop.header_background_color)
      styles = result.to_s
      replace_styles(styles)

      #replace the palceholder image tag with shop image or name based om if a shop has a logo
      introduction_division = @parsed_html.css('container[type=introduction]').first.css('division[type=introduction]').first
      introduction_division.css('img').each do |image|
        shop.has_logo? ? image.swap(%{<img src="#{shop.logo_location}">}) : image.swap(%{<h3>#{shop.name}</h3>})
      end
    end  

    def personalize_content
      #change the background color of the core content
      styles = fetch_styles
      result, extends = parse_css(styles)
      node = result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-core-content"}
      node.set_property('background-color', '#FFFFFF')
      styles = result.to_s
      replace_styles(styles)

      #change the background color of the sidebar
      styles = fetch_styles
      result, extends = parse_css(styles)
      node = result.find{|node| node.is_a?(Sass::Tree::RuleNode) && node.resolved_rules.to_s == ".optyn-sidebar"}
      node.set_property('background-color', '#C0C0C0')
      styles = result.to_s
      replace_styles(styles)
    end

    def personalize_footer
      #change the permission
      footer_node = @parsed_html.css('container[type=footer]').first.css('division[type=footer]').first
      permission_node = footer_node.css('permission').first
      shop_name_node = permission_node.css('shop-name').first
      shop_name_node.swap(shop.name)
      permission_node.swap("<p>#{permission_node.children.to_s}")

      #change the address node with shops address
      address_node = footer_node.css('address').first
      begin
        address_node.swap("<p>#{shop.message_address}</p>")
      rescue
        address_node.swap("<p>#{address_node.children.to_s}</p>")
      end
    end

    def fetch_styles
      styles = ""
      @parsed_html.css('style').each do |style|
        styles << style.children.to_s
      end
      styles
    end

    def parse_css(styles)
      engine = Sass::Engine.new(styles, :syntax => :scss)
      tree = engine.to_tree
      Sass::Tree::Visitors::CheckNesting.visit(tree)
      result = Sass::Tree::Visitors::Perform.visit(tree)
      Sass::Tree::Visitors::CheckNesting.visit(result)
      result, extends = Sass::Tree::Visitors::Cssize.visit(result)
      Sass::Tree::Visitors::Extend.visit(result, extends)

      [result, extends]
    end

    def replace_styles(styles)
      #replace the styles tag
      header = @parsed_html.css('style').first.parent
      @parsed_html.css('style').remove
      header.add_child(%{<style type="text/css">#{styles}</style>})
    end
end


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