module Shops
  module EatstreetRules
    def self.included(base)
      base.extend(ClassMethods)
    end

    def remaining_credits
      current_credit = fetch_current_credit
      current_credit.remaining_count if current_credit.present?
    end

    def fetch_current_credit
      shop_credits.fetch_credit(Time.now.beginning_of_month.beginning_of_day, Time.now.end_of_month.end_of_day)
    end

    private
      def adjust_shop_credits
        if partner_eatstreet?
          current_credit = fetch_credit
          current_credit.decrement
        end
      end

    public
    module ClassMethods
    end
  end #end of the EatstretRules module
end #end of the Shops module