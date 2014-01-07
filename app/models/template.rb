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
end