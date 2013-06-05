class DashboardsController < BaseController
  def index
    populate_counts
    populate_feed
  end

  private
  def populate_counts
    @pending_survey_count = current_user.unanswered_surveys_count
    @new_coupons_count = MessageUser.coupon_messages_count(current_user.id)
    @new_messages_count = MessageUser.new_messages_count(current_user.id)
    @new_specials_count = MessageUser.special_messages_count(current_user.id)
  end

  def populate_feed
    @feed = hasherize_messages +
        hasherize_connections +
        hasherize_recommendations +
        hasherize_surveys +
        hasherize_deactivated_connections

    @feed = @feed.shuffle.compact.slice(0, 19)
  end

  def hasherize_messages
    @latest_messages = MessageUser.latest_messages(current_user.id)
    @latest_messages.collect do |message_user|
      HashWithIndifferentAccess.new(
          {
              title: 'Message',
              shop_name: message_user.shop.name,
              image_url: message_user.shop.logo_img.url,
              subject: message_user.message.personalized_subject(message_user),
              excerpt: message_user.message.excerpt,
              action_url: message_path(message_user.message.uuid)
          }
      )
    end
  end

  def hasherize_connections
    @latest_connections = Connection.latest_connections(current_user.id)
    @latest_connections.collect do |connection|
      HashWithIndifferentAccess.new(
          {
              title: 'You Connected with',
              shop_name: connection.shop.name,
              image_url: connection.shop.logo_img.url,
              excerpt: connection.shop.description,
              action_url: (shop_connection_path(connection.shop.identifier) rescue '')
          }
      )
    end
  end

  def hasherize_recommendations
    @recommended_connections = User.recommend_connections(current_user.id)
    @recommended_connections.collect do |connection|
      HashWithIndifferentAccess.new(
          {
              title: 'Recommendation',
              shop_name: connection.shop.name,
              image_url: connection.shop.logo_img.url,
              excerpt: connection.shop.description,
              action_url: (shop_connection_path(connection.shop.identifier) rescue '')
          }
      )
    end
  end

  def hasherize_surveys
    @random_polls = current_user.dashboard_unanswered_surveys
    @random_polls.collect do |survey|
      HashWithIndifferentAccess.new(
          {
              title: 'Survey to get more personalized messages',
              shop_name: survey.shop.name,
              image_url: survey.shop.logo_img.url,
              excerpt: survey.shop.description,
              action_url: segment_path(Encryptor.encrypt(current_user.email, survey.id))
          }
      )
    end
  end

  def hasherize_deactivated_connections
    @deactivated_connections = Connection.dashboard_disconnected_connections(current_user.id)
    @deactivated_connections.collect do |connection|
      HashWithIndifferentAccess.new(
          {
              title: 'You Opted out of',
              shop_name: connection.shop.name,
              image_url: connection.shop.logo_img.url,
              excerpt: connection.shop.description,
              action_url: (shop_connection_path(connection.shop.identifier) rescue '')
          }
      )
    end
  end
end