module Shops
  module EatstreetRulesHelper
    def credits
      set_time_zone #skipping before filter in the controller
      @remaining_credits = current_shop.remaining_credits.to_i
    end
  end
end