namespace :eatstreet do
  desc "Populate the shop credits belonging to Eatstreet INC. partner"
  task :populate_shop_credits => :environment do
    partner = Partner.eatstreet
    if partner.present?
      shops = partner.shops
      shops.each do |shop|
        ShopTimezone.set_timezone(shop)
        current_credit = shop.fetch_current_credit
        beginning_this_month_day = Time.now.beginning_of_month.beginning_of_day
        end_this_month_day = Time.now.end_of_month.end_of_day
        if current_credit.blank?
          shop.shop_credits.create(remaining_count: ShopCredit::EATSTREET_MAX_CREDITS_COUNT, begins: beginning_this_month_day, ends: end_this_month_day)
        end

        next_month_day = Time.now.next_month
        beginning_next_month_day = next_month_day.beginning_of_month.beginning_of_day
        end_next_month_day = next_month_day.end_of_month.end_of_day
        following_credit = shop.shop_credits.fetch_credit(beginning_next_month_day, end_next_month_day)
        if following_credit.blank?
          shop.shop_credits.create(remaining_count: ShopCredit::EATSTREET_MAX_CREDITS_COUNT, begins: beginning_next_month_day, ends: end_next_month_day)
        end

        two_month_day = Time.now + 2.months
        beginning_two_month_day = two_month_day.beginning_of_month.beginning_of_day
        end_two_month_day = two_month_day.end_of_month.end_of_day
        following_credit = shop.shop_credits.fetch_credit(beginning_two_month_day, end_two_month_day)
        if following_credit.blank?
          shop.shop_credits.create(remaining_count: ShopCredit::EATSTREET_MAX_CREDITS_COUNT, begins: beginning_two_month_day, ends: end_two_month_day)
        end

        three_month_day = Time.now + 3.months
        beginning_three_month_day = three_month_day.beginning_of_month.beginning_of_day
        end_three_month_day = three_month_day.end_of_month.end_of_day
        following_credit = shop.shop_credits.fetch_credit(beginning_three_month_day, end_three_month_day)
        if following_credit.blank?
          shop.shop_credits.create(remaining_count: ShopCredit::EATSTREET_MAX_CREDITS_COUNT, begins: beginning_three_month_day, ends: end_three_month_day)
        end

      end
    end
  end 
end