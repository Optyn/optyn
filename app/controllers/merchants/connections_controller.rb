class Merchants::ConnectionsController < Merchants::BaseController
	include Merchants::LabelSetUpdate
	
  def index
    @connections = Connection.paginated_shops_connections(current_shop.id, params[:page])
    populate_labels
  end

  def unsubscribe_user
    shop_id = current_shop.id
  	connection = Connection.where(user_id:"#{params[:id]}", :shop_id => shop_id).first
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
      @error_hash = []
  		flag = false
  		loop_size = total_users.size - 1
  		(0..loop_size).each do |u|
        next if total_users[u].blank?
  			name_email_arr = total_users[u].strip.split("(")
  			name = name_email_arr[0].strip
  			email = name_email_arr[1].gsub(")", " ").strip
  			@user = User.new(:name => name, :email => email, :password => "test1234")
  			if not @user.save
          flag = true
          if @user.errors.full_messages[0].include?("invalid")
            @error_hash.push("#{email} is invalid.")
          else
            @error_hash.push("#{email} has already been taken.")
          end
        else
          @error_hash.push("#{email} was added successfully.")
          params["To"] = params["To"].gsub(name, "").gsub(email, "").gsub("(),", "").gsub("()", "")
          conn = Connection.create(:user_id => @user.id, :shop_id => current_shop.id, :connected_via => "Website")
          if not params["label_ids"].nil?
            total_labels_selected = params["label_ids"]
            label_loop_size = total_labels_selected.size - 1
            (0..label_loop_size).each do |l|
              user_label = UserLabel.find_or_create_by_user_id_and_label_id(user_id: @user.id, label_id: total_labels_selected[l])
            end
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
    respond_to do |format|
      format.html { render :layout => false}
    end
  end

  def update_user
  	@user = User.find(params[:id])
 		
	  if @user.update_attributes(name: "#{params[:name]}", email: "#{params[:email]}")
	    success_hash  = "User updated successfully."
      respond_to do |format|
        format.js { render :json => success_hash.to_json}
      end
	  else
	  	populate_labels
	    render 'edit', :layout => false
	  end
  end

  def search
    user_ids = User.search_user(params)
    @connections = Connection.where(:shop_id => current_shop.id, :user_id => user_ids).paginated_shops_connections(current_shop.id, params[:page])
    populate_labels
    render 'index'
  end

  def show
    @user = User.find(params[:id])
    @connection = Connection.where(:shop_id => current_shop.id, :user_id => @user.id).first
    populate_labels
    respond_to do |format|
      format.html { render :layout => false}
    end
  end

  private
  def populate_labels
    @names = current_shop.labels.active
  end
end
