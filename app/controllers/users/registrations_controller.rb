class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :require_manager_logged_out
end