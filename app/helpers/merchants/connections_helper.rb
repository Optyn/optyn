module Merchants::ConnectionsHelper
	def get_user_shop_labels(connection)
    user_shop_labels = "---"
    if not connection.user.user_labels.blank? 
      labels = connection.user.user_labels.select{|ul| ul.label.shop_id == current_shop.id if ul.label.active && !ul.label.blank?}
      if ((labels) and (!labels.empty?))
        user_shop_labels = labels.map{|s| s.label.name}.join(", ")
      end
    end
    return user_shop_labels
	end

  def check_gender(user_gender, current_gender)
    return user_gender == current_gender ?  true : false
  end
end