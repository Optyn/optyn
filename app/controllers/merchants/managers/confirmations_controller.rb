class Merchants::Managers::ConfirmationsController < Devise::ConfirmationsController
  before_filter :require_customer_logged_out

end