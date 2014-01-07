require 'nokogiri'
class Template < ActiveRecord::Base
  attr_accessible :shop_id, :system_generated, :name, :structure, :html

  serialize :structure, Hash

  has_many :messages
  has_many :stylesheets

  after_create :create_structure

  scope :fetch_system_generated, where(system_generated: true)

  scope :for_shop, ->(shop_identifier) { where(shop_id: shop_identifier) }

  scope :for_name, ->(template_name) { where(name: template_name) }

  PLACE_HOLDER_ELEM = "<placeholder></placeholder>\n"

  def self.system_generated 
    fetch_system_generated
  end

  def self.basic
    for_name("Basic")
  end

  def fetch_content(message_content)
    content = ""
    if message_content.blank?
      content = build_with_default_values
    else
    end
    content
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
            grid_child.css('division').each do |division_child|
              divisions << HashWithIndifferentAccess.new(html: division_child.children.to_s, type: division_child['type'])
              division_child.parent.add_child(add_newline(PLACE_HOLDER_ELEM)) unless division_child.parent.to_s.include?(PLACE_HOLDER_ELEM)
              division_child.remove
            end

            grid = HashWithIndifferentAccess.new(divisions: divisions)
            grid_parent = grid_child.parent
            grid_child.swap(add_newline(PLACE_HOLDER_ELEM))
            # grid_parent.add_child(PLACE_HOLDER_ELEM) unless row_child.to_s.include?(PLACE_HOLDER_ELEM)
            
            grid[:html] = grid_child.children.to_s
            grids << grid
          end


          row = HashWithIndifferentAccess.new(grids: grids)
          row_parent = row_child.parent
          row_child.swap(add_newline(PLACE_HOLDER_ELEM))
          # row_parent.add_child(PLACE_HOLDER_ELEM) unless _child.to_s.include?(PLACE_HOLDER_ELEM)

          row[:html] = row_child.children.to_s
          rows << row
        end

        container = HashWithIndifferentAccess.new(rows: rows, type: container_child['type'])
        container_parent = container_child.parent
        container_child.swap(add_newline(PLACE_HOLDER_ELEM))
        # container_parent.add_child(PLACE_HOLDER_ELEM) unless container_parent.parent.to_s.include?(PLACE_HOLDER_ELEM)

        container[:html] = container_child.children.to_s
        containers << container
        
      end

      wrapper[:html] = content.to_s

      self.structure = wrapper
      self.save

    end

    def build_with_default_values
      json_structure = self.structure
      containers_html = default_containers_html(json_structure)
      layout_html = json_structure.html

      containers_html.each do |container_html|
        layout_html = layout_html.sub(PLACE_HOLDER_ELEM, container_html)
      end

      layout_html
    end

    def default_containers_html(structure_hash)
      html = []
      structure_hash.containers.each do |container|
        rows_html = default_rows_html(container)
        container_html = container.html

        rows_html.each do |row_html|
          container_html = container_html.sub(PLACE_HOLDER_ELEM, row_html)
        end

        html << container_html
      end

      html
    end

    def default_rows_html(container)
      html = []
      container.rows.each do |row|
        grids_html = default_grids_html(row)
        row_html = row.html
        grids_html.each do |grid_html|
          row_html = row_html.sub(PLACE_HOLDER_ELEM, grid_html)
        end

        html << row_html
      end

      html
    end

    def default_grids_html(row)
      html = []
      row.grids.each do |grid|
        html << grid.html.gsub(PLACE_HOLDER_ELEM, grid.divisions.first.html)
      end
      html  
    end

    def add_newline(html)
      "\n" + html + "\n"
    end  
end