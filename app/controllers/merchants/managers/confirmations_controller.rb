class Merchants::Managers::ConfirmationsController < Devise::ConfirmationsController
  layout 'merchants'

  before_filter :require_customer_logged_out
  include MerchantSessionsRedirector

end