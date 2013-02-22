class Managers::PasswordsController < Devise::PasswordsController
  before_filter :require_manager


end