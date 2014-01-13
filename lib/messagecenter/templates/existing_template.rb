module Messagecenter
  module Templates
    class ExistingTemplate < MarkupGenerator
      attr_accessor :template, :content
      
      def initialize(options={})
        @template = options[:template]
        @content = options[:content]
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
            

            grids_html_arr = build_grid_markup(row_hash, template_row)
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
            #build the datamodel span
            components_json = add_toolset_to_components(template_grid.data_model) 
            data_model_html = %{<span style="width:0px;height:0px;" class="data-components" data-components='#{components_json}'></span>}  
            divisions_markup = build_division_markup(grid_hash, template_grid)
            content = data_model_html + raw(template_grid.html.gsub(Template::PLACE_HOLDER_ELEM, (static_toolset_markup(template_grid.data_model) + 
              divisions_markup.join)))

            html << content
          end

          html
        end

        def build_division_markup(grid, template_grid)
          html  = []
          grid['divisions'].each do |division_hash|
            template_div_html = template_grid.data_model[division_hash['type']].clone
            template_div_content = template_div_html['content']
            division_node = Nokogiri::HTML(template_div_content)
            headline = division_node.css('.optyn-headline').first()
            headline.content = division_hash if headline.present?

            paragraph = division_node.css('.optyn-paragraph').first()
            paragraph.content = division_hash if paragraph.present?            

            #TODO HANDLE MULTIPLE HEADLINES AND PARAGRAPHS
            # template_div_content = template_div_content.sub(, division_hash['headline'].to_s)
            # template_div_content = template_div_content.sub(/<paragraph>.*<\/paragraph>/, division_hash['paragraph'].to_s)
            html << template_div_content
          end
          html
        end  
    end #end of ExistingTemplate class
  end #end of templates module.
end #end of messagecenter module