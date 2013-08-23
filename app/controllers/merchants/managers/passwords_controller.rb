class Merchants::Managers::PasswordsController < Devise::PasswordsController
  layout 'application'

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      redirect_to(merchants_root_path, notice: "Password Reset Successful")
    else
      render action: 'edit'
    end
  end
end