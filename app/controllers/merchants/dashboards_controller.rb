class Merchants::DashboardsController < Merchants::BaseController
  def index
    populate_feed
  end

  private
  def populate_feed
    shop_id = current_shop.id
    @total_count = Connection.shop_connections_count_total(shop_id)
    @month_count = Connection.shop_connections_count_month(shop_id)
    @week_count = Connection.shop_connections_count_week(shop_id)
    @day_count = Connection.shop_connections_count_day(shop_id)
    @engagement_count = MessageUser.merchant_engagement_count(current_manager.id)
  end

  def populate_dashboard
    shop_id = current_shop.id
  end
end
