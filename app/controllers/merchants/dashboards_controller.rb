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
    @new_connections = current_shop.connections.order('updated_at DESC')
    @new_connections.collect do |connection|
      HashWithIndifferentAccess.new({
          type: 'New connection',
          time: connection.updated_at,
          user: connection.user.name,
          action_url: '/merchants/connections'
        })
    end
  end

  def hasherize_surveys
    @new_answered_surveys = SurveyAnswer.users(current_survey)
    @new_answered_surveys.collect do |submission|
      HashWithIndifferentAccess.new({
        type: 'New survey submission',
        time: submission.created_at,
        user: submission.user.name,
        action_url: merchants_survey_survey_answers_path
      })
    end
  end

  def hasherize_unfollowed_connections
    @disconnections = Shop.unfollowed_connections(current_shop)
    @disconnections.collect do |connection|
      HashWithIndifferentAccess.new({
          type: 'Revoked connection',
          time: connection.updated_at,
          user: connection.user.name,
          action_url: '#'
        })
    end
  end
end
