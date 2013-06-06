module Surveys
  module QuestionFieldType
    class FieldType
      @@PARENT_CLASS = nil
      @@CHILD_ATTRIBUTES = nil

      class << self
        def generate_markup(options)
          raise "Implement render_fields method for the type you chose!"
        end

        def default_size
          5
        end

        def wrapper_begin
          "<div class='beginningWrapper'>"
        end

        def wrapper_close
          "</div>"
        end

        def class_required(options)
          return "isRequired" unless options[:required]
        end

        def element_name(options)
          "#{parent_class}[#{child_attributes}][#{options[:id].split("_").last}][value][]"
        end

        def parent_class=(value)
          @@PARENT_CLASS = (value || "survey")
        end

        def parent_class
          @@PARENT_CLASS || "survey"
        end

        def child_attributes
          @@CHILD_ATTRIBUTES || "survey_answers_attributes"
        end

        def child_attributes=(value)
          @@CHILD_ATTRIBUTES = value || "survey_answers_attributes"
        end

        def default_text_attr(options)
          return %Q(
            default_val='#{options[:default_text]}'
            ) unless options[:default_text].blank?
        end
      end
    end

    class Input < FieldType
      class << self
        def generate_markup(options)
          elements_builder = ""
          options[:value] = [""] if options[:value].blank?
          options[:value].each do |value_elem|
            elements_builder.<<(create_element(Hash.new.merge(options).merge(:value => (value_elem rescue value_elem))))
          end
          return elements_builder
        end

        private
        def create_element(options)
          raise "Don't know the type of the input element" if options[:type].blank?
          %Q(#{wrapper_begin}
        <input
        type='#{options[:type]}'
        id='#{options[:id]}'
        name='#{element_name(options)}'
        class='#{options[:class]}'
          value='#{options[:value]}'
          />
          &nbsp;#{options[:value] if options[:type] != 'input'}
          #{wrapper_close})
        end
      end
    end

    class Radio < Input
      def self.generate_markup(options)
        super(options.merge(:type => "radio"))
      end
    end

    class Checkbox < Input
      def self.generate_markup(options)
        super(options.merge(:type => "checkbox"))
      end
    end

    class Text < Input
      def self.generate_markup(options)
        super(options.merge(:type => "text"))
      end
    end

    class Textarea < FieldType
      class << self
        def generate_markup(options)
          wrapper_begin(options) +
              %Q(<textarea
              class='#{default_class}'
              id='#{options[:id]}'
          name='#{element_name(options)}'
          cols='#{options[:cols]}'
          rows='#{options[:rows]}'
          #{default_text_attr(options)}>#{options[:default_text]}</textarea>) +
              wrapper_close
        end

        def default_class
          "big"
        end

        def wrapper_begin(options)
          "<div>"
        end
      end
    end

    class Select < FieldType
      class << self
        def generate_markup(options)
          wrapper_begin +
              beginning_element(options) +
              options[:value].collect do |option|
                %Q(<option #{"selected='selected'" if [*options[:selected]].include? option.strip}
          value='#{option.strip}'>#{option.strip}
          </option>)
              end.join("") +
              closing_element +
              wrapper_close
        end

        private
        def beginning_element(options)
          %Q(<select id='#{options[:id]}'
    name='#{element_name(options)}'
    class='#{options[:class]}'
      #{"value_id='#{options[:value_id]}'" unless options[:value_id].blank?}>)
        end

        def closing_element
          "</select>"
        end
      end
    end
  end
end