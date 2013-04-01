class Message < ActiveRecord::Base
  # attr_accessible :title, :body

  FIELD_TEMPLATE_TYPES = ["coupon_message", "event_message", "general_message", "product_message", "sale_message", "special_message", "survey_message"]
  DEFAULT_FIELD_TEMPLATE_TYPE = "general_message"

  def self.fetch_template_name(params_type)
    FIELD_TEMPLATE_TYPES.include?(params_type.to_s) ? params_type : DEFAULT_FIELD_TEMPLATE_TYPE
  end
end
