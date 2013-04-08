class BaseController < ApplicationController
  #Please don't write any actions here. This class is storing the common behavior for a logged in user.
  before_filter(:authenticate_user!)
  before_filter :redirect_to_account
  
  private
  def redirect_to_account
		if !current_user.blank? && !current_user.email.present?
			redirect_to edit_user_registration_path
		end
  end
end
