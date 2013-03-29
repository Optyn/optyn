class BaseController < ApplicationController
  #Please don't write any actions here. This class is storing the common behavior for a logged in user.
  before_filter(:authenticate_user!)

  private

end
