module Messagecenter
  module Templates
    class ExistingTemplate < MarkupGenerator
      attr_accessor :template, :content
      include ERB::Util
      
      def initialize(options={})
        @template = options[:template]
        @content = options[:content]
        @editable = options[:editable]
      end

      def build_markup
        template_structure = template.structure
        containers_html_arr = build_container_markup
        layout_markup = template_structure.html
        containers_html_arr.each do |container_html|
          layout_markup = layout_markup.sub(Template::PLACE_HOLDER_ELEM, container_html)
        end

        layout_markup
      end

      private
        def build_container_markup
          html = []

          template_containers = template.structure.containers

          content['containers'].each_with_index do |container_hash|
            template_container = template_containers.detect{|template_container| container_hash['type'] == template_container.type}
            
            rows_html_arr = build_row_markup(container_hash, template_container)
            container_markup = template_container.html
            rows_html_arr.each do |row_html|
              container_markup = container_markup.sub(Template::PLACE_HOLDER_ELEM, row_html)
            end

            html << container_markup
          end

          html
        end

        def build_row_markup(container, template_container)
          html = []
          container['rows'].each_with_index do |row_hash, index|
            template_row = template_container.rows[index]
            
            grids_html_arr = []
            if "false" == @editable.to_s
              grids_html_arr = build_grid_markup(row_hash, template_row)
            else
              grids_html_arr = build_editable_grid_markup(row_hash, template_row)
            end

            row_markup = template_row.html
            grids_html_arr.each do |grid_html|
              row_markup = row_markup.sub(Template::PLACE_HOLDER_ELEM, grid_html)
            end
            
            html << row_markup
          end

          html
        end

        def build_grid_markup(row, template_row)
          html = []
          row['grids'].each_with_index do |grid_hash, index|

            template_grid = template_row.grids[index]
            
            divisions_markup = build_division_markup(grid_hash, template_grid)
            
            content = raw(template_grid.html.gsub(Template::PLACE_HOLDER_ELEM, divisions_markup.join("\n")))
            html << content
          end

          html
        end

        def build_editable_grid_markup(row, template_row)
          html = []
          row['grids'].each_with_index do |grid_hash, index|

            template_grid = template_row.grids[index]
            #build the datamodel span
            components_json = add_toolset_to_components(template_grid.data_model) 
            data_model_html = %{<span style="width:0px;height:0px;" class="data-components" data-component-type="#{template_grid.data_model['type']}" data-components='#{components_json}'></span>}  
            
            divisions_markup = build_division_markup(grid_hash, template_grid)
            
            content = raw(template_grid.html.gsub(Template::PLACE_HOLDER_ELEM, (data_model_html + divisions_markup.join("\n"))))
            html << content
          end

          html
        end

        def build_division_markup(grid, template_grid)
          html  = []
          grid['divisions'].each do |division_hash|
            template_div_html = template_grid.data_model[division_hash['division']['type']].clone
            template_div_content = template_div_html['content']
            #TODO HANDLE MULTIPLE HEADLINES AND PARAGRAPHS
            division_node = Nokogiri::XML(template_div_content)

            headline = division_node.css('.optyn-headline').first()
            headline.inner_html = division_hash['division']['headlines'].first if headline.present?

            paragraph = division_node.css('.optyn-paragraph').first()
            paragraph.inner_html = division_hash['division']['paragraphs'].first if paragraph.present?

            toolset_markup = ""
            if  "true" == @editable.to_s
              toolset_markup = static_toolset_markup(template_grid.data_model)
            else
              toolset_markup = ""
            end

            html << toolset_markup + division_node.children.to_s # toolset_markup will be blank if @editable is false
          end
          html
        end  
    end #end of ExistingTemplate class
  end #end of templates module.
end #end of messagecenter module