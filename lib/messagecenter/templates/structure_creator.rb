module Messagecenter
  module Templates
    module StructureCreator
      include Merchants::MessagesHelper
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
                data_model = build_data_model(grid_child.css('division'), container_child['type'])

                grid_child.css('division').each do |division_child|
                  sanitize_division(division_child)
                  Messagecenter::Templates::MarkupGenerator.add_component_class(division_child, 'division')
                  Messagecenter::Templates::MarkupGenerator.add_data_type_to_component(division_child)  
                  social_sharing, component = add_social_share_components(division_child)                  
                  div = HashWithIndifferentAccess.new(html: division_child.children.to_s, type: division_child['type'])
                  div[:social_sharing] = social_sharing if social_sharing.present?

                  divisions << div
                  Messagecenter::Templates::MarkupGenerator.add_component_class(division_child, 'division')
                  division_child.parent.add_child(add_newline(Template::PLACE_HOLDER_ELEM)) unless division_child.parent.to_s.include?(Template::PLACE_HOLDER_ELEM)
                  
                  division_child.remove
                end

                grid = HashWithIndifferentAccess.new(divisions: divisions, data_model: data_model)
                grid_parent = grid_child.parent
                grid_child.swap(add_newline(Template::PLACE_HOLDER_ELEM))
                
                Messagecenter::Templates::MarkupGenerator.add_component_class(grid_child, 'grid')

                #search for social tags in html of the grid_child sand make apporpirate replacements with :social_sharing like the :html key
                social_sharing, grid_child = add_social_share_components(grid_child)
                grid[:social_sharing] = social_sharing if social_sharing.present?
                grid[:html] = grid_child.children.to_s
                
                grids << grid
              end


              row = HashWithIndifferentAccess.new(grids: grids)
              row_parent = row_child.parent
              row_child.swap(add_newline(Template::PLACE_HOLDER_ELEM))
              
              Messagecenter::Templates::MarkupGenerator.add_component_class(row_child, 'row')

              #search for social tags in html of the row_child sand make apporpirate replacements with :social_sharing like the :html key
              social_sharing, row_child = add_social_share_components(row_child)
              row[:social_sharing] = social_sharing if social_sharing.present?

              row[:html] = row_child.children.to_s
              rows << row
            end

            container = HashWithIndifferentAccess.new(rows: rows, type: container_child['type'])
            container_parent = container_child.parent
            container_child.swap(add_newline(Template::PLACE_HOLDER_ELEM))

            Messagecenter::Templates::MarkupGenerator.add_component_class(container_child, 'container')
            Messagecenter::Templates::MarkupGenerator.add_data_type_to_component(container_child)

            #search for social tags in html of the container_child sand make apporpirate replacements with :social_sharing like the :html key
            social_sharing, container_child = add_social_share_components(container_child)
            container[:social_sharing] = social_sharing if social_sharing.present?

            container[:html] = container_child.children.to_s
            
            containers << container
            
          end
          #search for social tags in html of the grid_child sand make apporpirate replacements with :social_sharing like the :html keys
          social_sharing, content = add_social_share_components(content)
          wrapper[:social_sharing] = social_sharing if social_sharing.present?
          wrapper[:html] = content.to_s

          self.structure = wrapper
          self.save

        end

        def add_social_share_components(component)
          #detect the social media nodes and put in placeholders and pass on a hash with the :social_sharing keys value
          #setting default html for facebook and twitter if placeholder tags are empty
          default_url = "http://optyn.com"
          default_text = "optyn"
          social_sharing = HashWithIndifferentAccess.new(:fb_sharing => {}, :twitter_sharing => {})
          fb_sharing = social_sharing[:fb_sharing]
          tw_sharing = social_sharing[:twitter_sharing]

          # facebook component
          component.css("fbshare").each do |fb_child|          
            fb_sharing[:url] = fb_child['shareurl'] 
            fb_sharing[:text] = fb_child['text'] || default_text
            fb_sharing[:html] = fb_child.children.any? ? fb_child.children.to_s : ""
            fb_child.swap(add_newline(Template::FB_PLACE_HOLDER_ELEM))

          end

          # twitter component
          component.css("twittershare").each do |tw_child|
            tw_sharing[:url] = tw_child['shareurl'] || default_url
            tw_sharing[:text] = tw_child['text'] || default_text
            tw_sharing[:via] = tw_child['via'] 
            tw_sharing[:recommend] = tw_child['recommend']
            tw_sharing[:html] = tw_child.children.any? ? tw_child.children.to_s : ""
            tw_child.swap(add_newline(Template::TW_PLACE_HOLDER_ELEM))
          end

          social_sharing = nil unless tw_sharing.present? || fb_sharing.present?
          [social_sharing, component]
        
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

          division_child.css('image').each do |image_child|
            Messagecenter::Templates::MarkupGenerator.add_image_placeholder_container(image_child)
            Messagecenter::Templates::MarkupGenerator.add_component_class(image_child, 'replaceable-image')
            # image_child.search('img').remove()  
            image_html = image_child.children.to_s
            image_child.swap(image_html)
          end
        end

        #build the data model when parsing the divisions for each row => grid when building the structure
        def build_data_model(divisions, type)
          data_model = {}

          data_model['type'] = type

          divisions.each do |division|
            data_model[division['type']] = {}
            div_hash = data_model[division['type']]
            div_hash['title'] = division['type'].to_s.humanize
            sanitize_division(division)
            Messagecenter::Templates::MarkupGenerator.add_component_class(division, 'division')
            Messagecenter::Templates::MarkupGenerator.add_data_type_to_component(division)
            #detect the social media tags inside the division content and put in placeholder and poplaute the social_sharing key            
            div_hash['content'] = division.children.to_s.squish
            div_hash['type'] = division['type']
          end

          data_model
        end

        def add_newline(html)
          "\n" + html + "\n"
        end

    end #end of the SystemTemplateParser module
  end #end of the Templates module
end #end of the Messagecenter module