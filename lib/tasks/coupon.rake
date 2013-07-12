namespace :coupon do
  desc "One off tasks to generate Stripe Coupons. The number needs to be provided as a ENV var"
  task :free_forever => :environment do
    unless ENV['COUPON_COUNT'].blank?
      count = ENV['COUPON_COUNT'].to_i
      count.times do |iterator|
        coupon_code = "opcu_#{Devise.friendly_token.first(14)}"
        while Coupon.find_by_stripe_id(coupon_code).present?
          coupon_code = "opcu_#{Devise.friendly_token.first(14)}"
        end

        coupon_attrs = {
            percent_off: 100,
            duration: 'forever',
            max_redemptions: 1,
            currency: "usd"
        } #attrs except coupon code

        stripe_coupon = Stripe::Coupon.create(coupon_attrs.merge(id: coupon_code))
        puts stripe_coupon.inspect
        coupon = Coupon.from_attrs(stripe_coupon)
        coupon.save!
      end
    else
      puts "=" * 100
      puts "Please enter the number of coupons you want to create."
      puts "^" * 100
    end
  end
end