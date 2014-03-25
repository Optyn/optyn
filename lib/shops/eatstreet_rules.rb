module Shops
  module EatstreetRules
    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        validate :allowed_to_queue, if: :partner_eatstreet?
      end
    end

    def needs_curation(change_state)
      return true if (self.state.blank? || self.draft? || self.pending_approval? || self.queued?) && ([:launch,:pending_approval].include? change_state)
      if (self.queued?) && partner.eatstreet? && self.valid?
        keys = changed_attributes.keys

        ['content', 'subject', 'percent_off', 'amount_off'].each do |attr|
          return true if keys.include?(attr)
        end
      end
      false
    end

    def for_curation(html, access_token=nil)
      MessageChangeNotifier.create(message_id: self.id, content: html, subject: self.subject, send_on: self.send_on, access_token: access_token)
    end

    private
      def adjust_shop_credits
        if partner_eatstreet?
          current_credit = shop.fetch_current_credit(sendon_months_beginning, sendon_months_ending)
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
        pending_messages = Message.pending_approvals_in_time_span((self.send_on - 3.days).beginning_of_day..self.send_on.end_of_day, shop.id).not_for_ids([self.id])
        messages.present? || pending_messages.present?
      end

      def messages_in_future?
        messages = Message.queued_in_time_span((self.send_on.beginning_of_day..(self.send_on.beginning_of_day + 3.days).end_of_day), shop.id).not_for_ids([self.id])
        pending_messages = Message.pending_approvals_in_time_span((self.send_on - 3.days).beginning_of_day..self.send_on.end_of_day, shop.id).not_for_ids([self.id])
        messages.present? || pending_messages.present?
      end

      def credits_not_available?
        available_credits = shop.remaining_credits(sendon_months_beginning, sendon_months_ending)
        queued_messages = Message.queued_in_time_span(sendon_months_beginning..sendon_months_beginning, shop.id).not_for_ids([self.id])
        pending_messages = Message.pending_approvals_in_time_span(sendon_months_beginning..sendon_months_beginning, shop.id).not_for_ids([self.id])
        ((available_credits - (queued_messages.size + pending_messages.size)) - 1) < 0 
      end

      def sendon_months_beginning
        send_on.beginning_of_month.to_datetime
      end

      def sendon_months_ending
        send_on.end_of_month.to_date.to_datetime
      end

    public
    module ClassMethods
      def queued_in_time_span(range, shop_id)
        for_state_and_shop(:queued, shop_id).scheduled_inrange(range)
      end

      def pending_approvals_in_time_span(range, shop_id)
        for_state_and_shop(:pending_approval, shop_id).scheduled_inrange(range)
      end
    end
  end #end of the EatstretRules module
end #end of the Shops module