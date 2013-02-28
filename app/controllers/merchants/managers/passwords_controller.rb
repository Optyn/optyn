class Merchants::Managers::PasswordsController < Devise::PasswordsController
  before_filter :require_no_manager

end