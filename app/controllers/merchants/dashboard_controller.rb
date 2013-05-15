class Merchants::DashboardController < Merchants::BaseController
  def index
    shop_id = current_shop.id
    @total_count = Connection.shop_connections_count_total(shop_id)
    @month_count = Connection.shop_connections_count_month(shop_id)
    @week_count = Connection.shop_connections_count_week(shop_id)
    @day_count = Connection.shop_connections_count_day(shop_id)
  end
end
