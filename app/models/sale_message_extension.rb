class SaleMessageExtension < ActiveRecord::Base
  belongs_to :message, :class_name => 'SaleMessage'
end