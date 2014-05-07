module Messagecenter
  module Templates
    class BlankTemplate < MarkupGenerator
      attr_accessor :template, :message 

      def initialize(options={})
        @template = options[:template]
        @message = options[:message]
        @editable = options[:editable]
      end

      # When a template is selected for the first time and no content  is added.
      def build_markup
        json_structure = @template.structure
        containers_html = default_containers_html(json_structure)
        layout_html = json_structure.html

        containers_html.each do |container_html|
          layout_html = layout_html.sub(Template::PLACE_HOLDER_ELEM, container_html)
        end
        layout_html = build_social_sharing_options(json_structure,layout_html)
        layout_html
      end


      private
        def default_containers_html(structure_hash)
          html = []
          structure_hash.containers.each do |container|
            rows_html = default_rows_html(container)
            container_html = container.html

            rows_html.each do |row_html|
              container_html = container_html.sub(Template::PLACE_HOLDER_ELEM, row_html)
            end
            container_html = build_social_sharing_options(container,container_html)
            html << container_html
          end

          html
        end

        def default_rows_html(container)
          html = []
          container.rows.each do |row|

            grids_html = ""
            if "false" == @editable
              grids_html = default_grids_html(row)
            else
              grids_html = default_editable_grids_html(row)
            end

            row_html = row.html
            grids_html.each do |grid_html|
              row_html = row_html.sub(Template::PLACE_HOLDER_ELEM, grid_html)
            end
            #replace the social tags row_html
            row_html = build_social_sharing_options(row,row_html)
            html << row_html
          end

          html
        end

        def default_grids_html(row)
          html = []
          row.grids.each do |grid|
            content = grid.html.gsub(Template::PLACE_HOLDER_ELEM, grid.divisions.first.html)
            #replace the social tags
            content = build_social_sharing_options(grid,content)
            content = build_social_sharing_options(grid.divisions.first,content)
            html << content
          end
          html  
        end

        def default_editable_grids_html(row)
          html = []
          row.grids.each do |grid|
            components_json = add_toolset_to_components(grid.data_model) 
            data_model = %{<span style="width:0px;height:0px;" class="data-components" data-component-type="#{grid.data_model['type']}" data-components='#{components_json.gsub("'", "&apos;")}''></span>}  
            content =  grid.html.gsub(Template::PLACE_HOLDER_ELEM, (data_model + static_toolset_markup(grid.data_model) + grid.divisions.first.html))
            #replace the social tags
            content = build_social_sharing_options(grid.divisions.first,content)
            content = build_social_sharing_options(grid,content)
            html << content
          end
          
          html  
        end
    end #end of BlankMarkup class
  end #end of templates module.
end #end of messagecenter module  