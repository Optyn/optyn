class Merchants::Managers::PasswordsController < Devise::PasswordsController
	include MerchantSessionsRedirector
end