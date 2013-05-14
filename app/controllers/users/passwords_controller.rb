class Users::PasswordsController < Devise::PasswordsController
  before_filter :require_manager_logged_out
  def create
    user  = User.find_by_email(resource_params[:email])
    manager = Manager.find_by_email(resource_params[:email])
    klass = user.present? ? User : (manager.present? ? Manager : User)

    self.resource = klass.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end
end