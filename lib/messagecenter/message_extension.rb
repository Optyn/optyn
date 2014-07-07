require 'active_support/concern'

module Messagecenter
  module MessageExtension
    extend ActiveSupport::Concern

    #TOFIX: Boolean attributes when set from forms, will not hold true/false values 
    # (something handled explicitly by active record) but instead '1'/'0'. Be careful when using them
    # in coditions before the message is saved
    # The after_save :load_extension is deliberately used as a partial fix for the problem.

    module ClassMethods
      def has_extension(options={})
        include ExtensionMethods
        
        cattr_accessor :extension_attribute_names
        self.extension_attribute_names = options.delete(:attrs)
        has_one :extension, options

        attr_accessor *self.extension_attribute_names
        attr_accessible *self.extension_attribute_names

        after_initialize :load_extension
        before_save :save_extension
        # to reinitialize boolean values that have been reset from forms to true/false instead of '1'/'0'
        after_save :load_extension
        before_destroy :destroy_extension

    	  default_scope { includes :extension }
      end
    end

    module ExtensionMethods
      def load_extension
      	extension = self.extension || self.build_extension
      	self.class.extension_attribute_names.each do |attr_name|
      	  eval "@#{attr_name} = extension.#{attr_name}"
      	end
      end

      def save_extension
      	extension = self.extension || self.build_extension
      	self.class.extension_attribute_names.each do |attr_name|
      	  eval "extension.#{attr_name} = @#{attr_name}"
      	end
        extension.save
      end

      def destroy_extension
      	self.extension.destroy if self.extension.exists?
      end
    end
  end
end