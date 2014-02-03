class Merchants::ConnectionsController < Merchants::BaseController
	include Merchants::LabelSetUpdate
	
  def index
    @connections = Connection.paginated_shops_connections(current_shop.id, params[:page])
    populate_labels
  end

  def unsubscribe_user
    shop_id = current_shop.id
  	connection = Connection.where(user_id:"#{params[:id]}", :shop_id => shop_id).first
    user = User.find(params[:id])
    user.destroy_all_user_labels
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
    @error_hash = []
    @user = User.new
    if params["To"].blank? && params["label_ids"].nil?
      @error_hash.push("Please enter email and name ")
      @error_hash.push("Please enter labels")
      populate_labels
      render 'add_user'
    elsif params["To"].nil?
      @error_hash.push("Please enter email and name ")
      populate_labels
      render 'add_user'	
    elsif params["label_ids"].nil?
      @error_hash.push("Please enter labels")
      populate_labels
      render 'add_user'
    elsif not params["To"].blank?
  		total_users = params["To"].split(",")
      
  		flag = false
  		loop_size = total_users.size - 1
      
  		(0..loop_size).each do |u|
        next if total_users[u].blank?
  			
        if total_users[u].match(/(?<=\().*?(?=\))/)
          name_email_arr = total_users[u].strip.split("(")
    			name = name_email_arr[0].strip
    			email = name_email_arr[1].scan(/.*?(?=\))/).first.strip
        else
          email = total_users[u].strip
        end


          
  			@user.name = name
        @user.email = email
        @user.password = "test1234"
        @user.skip_name = true
        @user.shop_identifier = current_shop.id
        @user.show_shop = true
        conn = nil
  
  			if not @user.save
          if @user.errors.full_messages[0].include?("invalid")
            flag = true
            @error_hash.push("#{email} is invalid.")
            next
          elsif @user.errors[:email]
            
            #Email belongs to existing User.
            if @user.errors[:email].include?("has already been taken")
              existing_user = User.find_by_email(email)
              existing_connection = Connection.where(:user_id => existing_user.id, :shop_id => current_shop.id)
              #Connection with the shop, exists
              if not existing_connection.empty?
                existing_connection = existing_connection.first
                #If connection is not active, make it active.
                if not existing_connection.active
                  conn = existing_connection
                  @user = existing_user
                  #If connection is active, return.
                else
                  flag = true
                  @error_hash.push("#{email} has already been taken.")
                  next
                end
                #User exixts, but does not have connection with the current shop.
              else
                @user = existing_user
              end

              #Email belongs to existing Manager.
            elsif @user.errors[:email].include?("already taken")
              flag = true
              @error_hash.push("#{email} has already been taken.")
              next
            end
          end
        end
        
        @error_hash.push("#{email} was added successfully.")
        params["To"] = total_users - total_users[u].split(",")
        params["To"] = params["To"].join(",")
        # params["To"] = params["To"].gsub(name, "").gsub(email, "").gsub("(),", "").gsub("()", "")
        if conn
          conn.active = true
          conn.save
        else
          conn = Connection.create(:user_id => @user.id, :shop_id => current_shop.id, :connected_via => "Website")
        end
        if not params["label_ids"].nil?
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
    respond_to do |format|
      format.html { render :layout => false}
    end
  end

  def update_user
  	@user = User.find(params[:id])
 		
	  if @user.update_attributes(name: "#{params[:name]}", email: "#{params[:email]}")
	    @success_hash  = "User updated successfully."
	  else
	  	populate_labels
	  end
    render 'edit', :layout => false
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
