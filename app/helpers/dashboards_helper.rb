module DashboardsHelper
  def feed_description(feed_element)
    description = feed_element['excerpt']
    description.blank? ? "No description available" : description
  end
end