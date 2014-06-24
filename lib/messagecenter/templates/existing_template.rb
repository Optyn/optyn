module Messagecenter
  module Templates
    class ExistingTemplate < MarkupGenerator
      attr_accessor :template, :content, :message
      include ERB::Util
      
      def initialize(options={})
        @template = options[:template]
        @message = options[:message]
        @content = JSON.parse(@message.content)
        @editable = options[:editable]
      end

      def build_markup
        template_structure = template.structure
        containers_html_arr = build_container_markup
        layout_markup = template_structure.html
        containers_html_arr.each do |container_html|
          layout_markup = layout_markup.sub(Template::PLACE_HOLDER_ELEM, container_html)
        end
        layout_markup = build_social_sharing_options(template_structure,layout_markup)
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
            container_markup = build_social_sharing_options(template_container,container_markup)
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
            row_markup = build_social_sharing_options(template_row,row_markup)
            html << row_markup
          end

          html
        end

        def build_grid_markup(row, template_row)
          html = []
          row['grids'].each_with_index do |grid_hash, index|
            template_grid = template_row.grids[index]
            
            divisions_markup = build_division_markup(grid_hash, template_grid)
            
            content = template_grid.html.gsub(Template::PLACE_HOLDER_ELEM, divisions_markup.join("\n"))
            content = build_social_sharing_options(template_grid,content)
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
            data_model_html = %{<span style="width:0px;height:0px;" class="data-components" data-component-type="#{template_grid.data_model['type']}" data-components='#{components_json.gsub("'", "&apos;")}'></span>}  
            
            divisions_markup = build_division_markup(grid_hash, template_grid)
            content = template_grid.html.gsub(Template::PLACE_HOLDER_ELEM, (data_model_html + divisions_markup.join("\n")))
            content = build_social_sharing_options(template_grid,content)
            html << content
          end

          html
        end

        def build_division_markup(grid, template_grid)
          html  = []
          if grid['divisions'].present?
            grid['divisions'].each do |division_hash|
              template_div_html = template_grid.data_model[division_hash['division']['type']].clone
              template_div_content = template_div_html['content']
              template_div_content = build_social_sharing_options(template_div_html,template_div_content)
              division_node = Nokogiri::HTML::fragment(template_div_content)
              

              #headlines added
              (division_hash['division']['headlines'] || []).each_with_index do |headline_content, index|
                headline = division_node.css('.ss-headline')[index]
                headline.inner_html = headline_content
              end

              #paragraph added
              (division_hash['division']['paragraphs'] || []).each_with_index do |paragraph_content, index|
                paragraph = division_node.css('.ss-paragraph')[index]
                paragraph.inner_html = paragraph_content.gsub(/&nbsp;/, Template::OPTYN_SPACE_PLACEHOLDER)
              end

              #images added
              (division_hash['division']['images'] || []).each_with_index do |image_content, index|
                image_container = division_node.css('.ss-replaceable-image')[index]
                image_alt = image_content['alt'].present? ? image_content['alt'] : ""
                begin
                  if image_content['href'].blank?
                    img_elem = %{<img src="#{image_content['url']}" height="#{image_container['height']}" width="#{image_container['width']}" style="#{image_content['style']}" class="#{image_content['class']}" alt="#{image_alt}" />}
                  else
                    img_elem = %{<a href="#{image_content['href']}" target="_blank" class="imageLink"><img src="#{image_content['url']}" height="#{image_container['height']}" width="#{image_container['width']}" style="#{image_content['style']}" class="#{image_content['class']}" alt="#{image_alt}" /></a>}
                  end
                  image_container.inner_html = img_elem
                rescue
                  ""
                end
              end            

              toolset_markup = ""
              if  "true" == @editable.to_s
                toolset_markup = static_toolset_markup(template_grid.data_model)
              else
                toolset_markup = ""
              end

              html << toolset_markup + division_node.to_s # toolset_markup will be blank if @editable is false
            end
          else
            html << ("true" == @editable.to_s ? static_toolset_markup(template_grid.data_model, true) : "")
          end
          html
        end  
    end #end of ExistingTemplate class
  end #end of templates module.
end #end of messagecenter module