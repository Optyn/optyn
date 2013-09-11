class MainController < ApplicationController
  before_filter :require_not_logged_in, only: [:index]

end
