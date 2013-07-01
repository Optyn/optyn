class OauthAuthorizationsController < Doorkeeper::AuthorizationsController
  layout 'oauth_dialog'

  prepend_before_filter :increment_button_click_count

  def new
    if pre_auth.authorizable?
      if Doorkeeper::AccessToken.matching_token_for(pre_auth.client, current_resource_owner.id, pre_auth.scopes) || skip_authorization?
        auth = authorization.authorize

        respond_to do |format|
          format.html { redirect_to auth.redirect_uri }
          format.json { render(json: {data: {code: auth.auth.token.token}}) }
        end
      else
        respond_to do |format|
          format.html { render :new }
          format.json { render(status: :accepted, json: {data: {user_permission_requested: true}}) }
        end
      end
    else
      render :error
    end
  end

  def create
    auth = authorization.authorize

    if auth.redirectable?
      respond_to do |format|
        format.html {redirect_to auth.redirect_uri}
        format.json{render(status: :created, json: {data: {code: auth.auth.token.token}})}
      end
    else
      render :json => auth.body, :status => auth.status
    end
  end

  def destroy
    auth = authorization.deny

    if auth.redirectable?
      respond_to do |format|
        format.html {redirect_to auth.redirect_uri}
        format.json{render json: {data: auth.body}, :status => auth.status}
      end
    else
      render :json => auth.body, :status => auth.status
    end
  end


  def show
    super
    if params[:callback].present?
      render text: "#{params[:callback]}('#{{code: params[:code]}.to_json}')"
    end
  end

  private
  def increment_button_click_count
    @shop = Shop.by_app_id(params[:client_id])
    @shop.increment_click_count if @shop.present?
  end
end
