class SpecialMessageExtension < ActiveRecord::Base
  belongs_to :message, :class_name => 'SpecialMessage'
end