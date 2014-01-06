require 'nokogiri'
class Template < ActiveRecord::Base
  attr_accessible :shop_id, :system_generated, :name, :structure, :html

  serialize :structure, Hash

  has_many :messages
  has_many :stylesheets

  after_create :create_structure

  scope :fetch_system_generated, where(system_generated: true)

  scope :include_sections, includes(:sections)

  scope :for_shop, ->(shop_identifier) { where(shop_id: shop_identifier) }

  scope :for_name, ->(template_name) { where(name: template_name) }

  def self.system_generated 
    fetch_system_generated.include_sections
  end

  def self.basic
    for_name("Basic")
  end

  private
    def create_structure
      content = Nokogiri::HTML(self.html)
      #start traversing the hierarchy goes as:
      #containers => rows => grids => columns => editable content
      wrapper = HashWithIndifferentAccess.new(containers: [], html: "")

      containers = wrapper[:containers]
      content.css('container').each do |container_child|
        
        rows = []
        container_child.css('row').each do |row_child|

          grids = []
          row_child.css('grid').each do |grid_child|
            columns = []
            grid_child.css('columns').each do |columns_child|
              columns << HashWithIndifferentAccess.new(html: columns_child.children.to_s, type: columns_child['type'])
              columns_child.parent.replace("<placeholder></placeholder>")
            end

            grid = HashWithIndifferentAccess.new(columns: columns)
            grid_child.parent.replace("<placeholder></placeholder>")
            grid[:html] = grid_child.children.to_s
            grids << grid
          end


          row = HashWithIndifferentAccess.new(grids: grids)
          row_child.parent.replace("<placeholder></placeholder>")
          row[:html] = row_child.children.to_s
          rows << row
        end

        container = HashWithIndifferentAccess.new(rows: rows, type: container_child['type'])
        container_child.parent.replace("<placeholder></placeholder>")
        container[:html] = container_child.children.to_s
        containers << container
        
      end

      wrapper[:html] = content.to_s

      self.structure = wrapper
      self.save      

      # #populate the introduction section
      # introduction = content.css('introduction').children.to_s
      # self.sections.create_introduction!(introduction)

      # #populate the conslusion section
      # conclusion = content.css('conclusion').children.to_s
      # self.sections.create_introduction!(conclusion) 

      # #populate the wrapper => rows inside it
      # wrapper = content.css('wrapper')
      # rows = content.css('row')    
      # rows.each do |row|
      #   self.sections.create_row!(row)  
      # end


    end
end