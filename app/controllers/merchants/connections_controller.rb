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

  def add_user
  	@user = User.new
  	populate_labels
  end

  def create_user
  	if not params["To"].blank?
  		total_users = params["To"].split(",")
  		flag = false
  		loop_size = total_users.size - 1
  		(0..loop_size).each do |u|
  			name_email_arr = total_users[u].strip.split("(")
  			name = name_email_arr[0].strip
  			email = name_email_arr[1].gsub(")", " ").strip
  			@user = User.new(:name => name, :email => email, :password => "test1234")
  			if not @user.save
          flag = true
          break
        else
          params["To"] = params["To"].gsub(name, "").gsub(email, "").gsub("(),", "")
          conn = Connection.create(:user_id => @user.id, :shop_id => current_shop.id, :connected_via => "Website")
          total_labels_selected = params["label_ids"]
          label_loop_size = total_labels_selected.size - 1
          (0..label_loop_size).each do |l|
            user_label = UserLabel.find_or_create_by_user_id_and_label_id(user_id: @user.id, label_id: total_labels_selected[l])
          end
        end
  		end

  		if not flag
	  		redirect_to merchants_connections_path, :notice => "User(s) added successfully."
	  	else
        populate_labels
	  		render 'add_user'	
	  	end
  	else
  		populate_labels
      @user = User.new(:name => params["To"])
      @user.save
      render 'add_user'
  	end
  end

  def create_labels_for_user
  	existing_label = current_shop.labels.find_by_name(params[:label].strip)
    label = current_shop.labels.create(name: params[:label].strip) unless existing_label.present?

    render json: (label.attributes.except('shop_id', 'created_at', 'updated_at') rescue []).to_json
  end

  def edit
  	@user = User.find(params[:id])
  	populate_labels
  end

  def update
  	@user = User.find(params[:id])
 		
	  if @user.update_attributes(name: "#{params[:user][:name]}", email: "#{params[:user][:email]}")
	    redirect_to merchants_connections_path, :notice => "User updated successfully."
	  else
	  	populate_labels
	    render 'edit'
	  end
  end

  private
  def populate_labels
    @names = current_shop.labels.active
  end
end
