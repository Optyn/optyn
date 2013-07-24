class MainController < ApplicationController
  before_filter :require_not_logged_in, only: [:index]

  def index
    render layout: 'flat'
  end

  def terms
    render layout: 'flat'
  end

end
