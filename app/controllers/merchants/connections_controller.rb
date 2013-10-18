class Merchants::ConnectionsController < Merchants::BaseController
	include Merchants::LabelSetUpdate
	
  def index
    @connections = Connection.paginated_shops_connections(current_shop.id, params[:page])
    populate_labels
  end

  def unsubscribe_user
  	connection = Connection.where(user_id:"#{params[:id]}").first
  	if connection
  		connection.active = "false"
  		connection.save
  	end

  	redirect_to merchants_connections_path, :notice => "User unsubscribed successfully."
  end

  def create_label
    create_label_helper_method_called
  end

  def update_labels
    update_labels_helper_method_called
  end

  private
  def populate_labels
    @names = current_shop.labels.active
  end
end
