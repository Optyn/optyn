class Merchants::Managers::PasswordsController < Devise::PasswordsController
  layout 'merchants'

	include MerchantSessionsRedirector
end