class Merchants::Managers::ConfirmationsController < Devise::ConfirmationsController
  before_filter :require_no_manager

end