class Users::PasswordsController < Devise::PasswordsController
  before_filter :require_manager_logged_out
  def create
    super
  end
end