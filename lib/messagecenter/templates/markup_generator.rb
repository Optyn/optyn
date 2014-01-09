module Messagecenter
  module Templates
    class MarkupGenerator
      include ActionView::Helpers::TagHelper
      include ERB::Util
      include ActionView::Helpers::OutputSafetyHelper

      attr_accessor :template
      def self.generate(content, template)
        parsed_content = JSON.parse(content)
        markup = ""
        if content.blank?
          blank_template = BlankTemplate.new(template: template)
          markup = blank_template.build_markup
        else
          existing_template = ExistingTemplate.new(template: template, content: parsed_content)
          markup = existing_template.build_markup
        end  

        markup
      end

      def add_toolset_to_components(data_model)
        components_hash = data_model.clone
        toolset_markup = static_toolset_markup(components_hash)
        components_hash.each_pair do |component_name, compoenent_content|
          components_hash[component_name] = toolset_markup + compoenent_content['content']
        end

        components_hash.to_json
      end

      def static_toolset_markup(grid_data_model)
        dropdown_links  = ""
        grid_data_model.each_pair do |key, val|
          dropdown_links += '<li>' + '<a class="add-section-link" href="#"' + ' data-section-type= ' + '"' + val['title'] + '"' + '>' + '&nbsp;&nbsp;' + val['title'] + '&nbsp;</a>' + '</li>'
        end

        '<div class="row template-section-toolset"><div class="btn-group pull-right"><button class="btn ink-action-edit"><i class="icon-edit icon-white"></i></button><button class="btn ink-action-delete"><i class="icon-trash icon-white action-delete"></i></button><a class="btn dropdown-toggle" data-toggle="dropdown" href="#"><i class="icon-plus icon-white">&nbsp;<span class="caret"></span></a><ul class="dropdown-menu">' + 
        dropdown_links +       
        '</ul></div></div>' 
      end

    end #end of the MarkupGenerator class
  end #end of templates module.
end #end of messagecenter module