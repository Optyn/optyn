module Shops
  module EatstreetRules
    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        validate :allowed_to_queue, if: :partner_eatstreet?
      end
    end

    def remaining_credits
      current_credit = fetch_current_credit
      current_credit.remaining_count if current_credit.present?
    end

    def fetch_current_credit
      shop.shop_credits.fetch_credit(current_months_beginning, current_months_ending)
    end

    private
      def adjust_shop_credits
        if partner_eatstreet?
          current_credit = fetch_credit
          current_credit.decrement
        end
      end

      def allowed_to_queue
        if time_gap_not_met?
          self.errors.add(:base, "You need to have a gap of atleast 3 days between sending out campaigns")
        elsif credits_not_available?
          self.errors.add(:base, "Sorry, you are allowed 4 campaigns a month and this campaign will the limit")
        end
      end

      def time_gap_not_met?
        messages_in_past? || messages_in_future?        
      end

      def messages_in_past?
        messages = Message.queued_in_time_span((self.send_on - 3.days).beginning_of_day..self.send_on.end_of_day, shop.id).not_for_ids([self.id])
        messages.present?
      end

      def messages_in_future?
        messages = Message.queued_in_time_span((self.send_on.beginning_of_day..(self.send_on.beginning_of_day + 3.days).end_of_day), shop.id).not_for_ids([self.id])
        messages.present?
      end

      def credits_not_available?
        available_credits = remaining_credits
        queued_messages = Message.queued_in_time_span(current_months_beginning..current_months_ending, shop.id).not_for_ids([self.id])
        ((available_credits - queued_messages.size) - 1) < 0 
      end

      def current_months_beginning
        send_on.beginning_of_month.to_date
      end

      def current_months_ending
        send_on.end_of_month.to_date
      end

    public
    module ClassMethods
      def queued_in_time_span(range, shop_id)
        for_state_and_shop(:queued, shop_id).scheduled_inrange(range)
      end
    end
  end #end of the EatstretRules module
end #end of the Shops module