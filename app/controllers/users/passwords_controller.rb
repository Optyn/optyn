class Users::PasswordsController < Devise::PasswordsController
  before_filter :require_manager_logged_out
  append_before_filter :populate_user_and_manager, :user_logged_in_through_social, only: [:create]

  def create

    self.resource = @klass.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      redirect_to(consumers_root_path)
    else
      render action: 'edit'
    end
  end

  private
  def populate_user_and_manager
    @user = User.find_by_email(resource_params[:email])
    @manager = Manager.find_by_email(resource_params[:email])
    @klass = @manager.present? ? Manager : (@user.present? ? User : Manager)
  end

  def user_logged_in_through_social
    if @klass == User
      if @user.present? && @user.authentications.present?
        set_logged_in_through_social_message
        redirect_to new_user_password_path
      end
    elsif @klass == Manager
      if @manager.present? && @manager.authentications.present?
        set_logged_in_through_social_message
        redirect_to new_user_password_path
      end
    end
  end

  def set_logged_in_through_social_message
    flash[:alert] = "Looks like you logged in using one of your social media accounts."
  end
end