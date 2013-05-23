class ConnectionsController < BaseController
  include DashboardCleaner

  before_filter :verify_shop, :fetch_connection, only: [:shop, :disconnect, :connect]
  around_filter :flush_new_connections, only: [:add_connection, :connect]
  around_filter :flush_disconnected_connections, only: [:disconnect, :add_connection]

  def index
    @connections = current_user.active_connections(params[:page])
  end

  def make
    @shops = Shop.disconnected_connections(current_user.active_shop_ids)
  end

  def dropped
    @connections = current_user.inactive_connections(params[:page])
  end

  def add_connection
    @shop = Shop.find(params[:shop_id])
    begin
      if @shop.present?
        if current_user.shop_ids.include?(@shop.id)
          @connection = current_user.connections.where(:shop_id => @shop.id).first
          if @connection.toggle_connection
            @flush = true
            followed=@connection.active
            render :json => {:success => true, :success_text => @connection.connection_status, :hover_text => "Unfollow", :followed => followed}
          else
            render :json => {:success => false, :success_text => @connection.connection_status, :error_message => "Connection failed"}
          end
        else
          @connection = current_user.connections.new(:shop_id => @shop.id)
          if @connection.save
            @flush = true
            followed=@connection.active
            render :json => {:success => true, :success_text => "Following", :followed => followed}
          else
            render :json => {:success => false, :success_text => "Opt In", :error_message => "Connection failed"}
          end
        end
      end
    rescue
      render :json => {:success => false, :error_message => "Oops, Something went wrong."}
    end
  end

  def shop
    @active = @connection.present?
  end

  def disconnect
    unless @connection.present?
      flash[:alert] = "Sorry could not disconnect you from this store. Please try again a little later." &&
          redirect_to(params[:return_to] || connections_path) &&
          return
    end

    @connection.update_attribute(:active, false)
    @flush = true
    redirect_to(params[:return_to] || dropped_connections_path, notice: "Connection with #{@shop.name} successfully deactivated.")
  end

  def connect
    @connection = current_user.connections.find_by_shop_id(@shop.id) #include deactivated as well
    unless @connection.present?
      @connection = Connection.new()
      @connection.user_id = current_user.id
      @connection.shop_id = @shop.id
    end

    @connection.active = true
    @flush = true
    @connection.save
    redirect_to(params[:return_to] || connections_path, notice: "Connection with #{@shop.name} successfully created.")
  end

  private
  def verify_shop
    @shop = Shop.find_by_identifier(params[:id])
    flash[:alert] = "Sorry. Could not find the shop" and redirect_to(consumer_dashboard_path) if @shop.blank?
  end

  def fetch_connection
    @connection = current_user.connections.active.find_by_shop_id(@shop.id)
  end
end
