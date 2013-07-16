class Merchants::DashboardsController < Merchants::BaseController
  def index
    populate_counts
    populate_feed
  end

  private
  def populate_counts
    shop_id = current_shop.id
    @total_count = Connection.shop_connections_count_total(shop_id)
    @month_count = Connection.shop_connections_count_month(shop_id)
    @week_count = Connection.shop_connections_count_week(shop_id)
    @day_count = Connection.shop_connections_count_day(shop_id)
    @engagement_count = MessageUser.merchant_engagement_count(current_manager.id)
  end

  def populate_feed
    shop_id = current_shop.id
    @feed = hasherize_connections +
            hasherize_surveys +
     hasherize_unfollowed_connections
    @feed = @feed.shuffle.compact.slice(0, 19)
  end

  private
  def populate_dashboard
    shop_id = current_shop.id
  end

  def hasherize_connections
    @new_connections = Connection.shop_latest_connections(current_shop.id)
    @new_connections.collect do |connection|
      HashWithIndifferentAccess.new({
          type: 'New connection',
          time: connection.updated_at,
          user: connection.user.display_name,
          action_url: merchants_connections_path
        })
    end
  end

  def hasherize_surveys
    @survey_users = SurveyAnswer.users(current_shop.id, current_survey.id)
    @survey_users.collect do |answer|
      HashWithIndifferentAccess.new({
        type: 'New survey submission',
        time: Time.at(answer.last.to_i),
        user: answer.first,
        action_url: merchants_survey_survey_answers_path
      })
    end
  end

  def hasherize_unfollowed_connections
    @disconnections = Connection.shop_dashboard_disconnected_connections(current_shop.id)
    @disconnections.collect do |connection|
      HashWithIndifferentAccess.new({
          type: 'Revoked connection',
          time: connection.updated_at,
          user: connection.user.display_name,
          action_url: nil
        })
    end
  end
end
