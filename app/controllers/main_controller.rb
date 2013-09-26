class MainController < ApplicationController
  layout 'application'

  before_filter :require_not_logged_in, only: [:index]
  before_filter :skip_menu

  private
  def skip_menu
    @skip_menu = true
  end
end
