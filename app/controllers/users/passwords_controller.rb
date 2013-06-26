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

  private
  def populate_user_and_manager
    @user = User.find_by_email(resource_params[:email])
    @manager = Manager.find_by_email(resource_params[:email])
    @klass = @user.present? ? User : (@manager.present? ? Manager : User)
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