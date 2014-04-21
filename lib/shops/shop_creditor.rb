module Shops
  module ShopCreditor
    def self.included(base)
      base.class_eval do
        has_many :shop_credits
      end 
    end

    def fetch_current_credit(begin_stamp, ending_stamp)
      shop_credits.fetch_credit(begin_stamp, ending_stamp)
    end

    def remaining_credits(begin_timestamp=Time.now.beginning_of_month.beginning_of_day, ending_timestamp=Time.now.end_of_month.end_of_day)
      current_credit = fetch_current_credit(begin_timestamp, ending_timestamp)
      current_credit.remaining_count if current_credit.present?
    end
  end
end