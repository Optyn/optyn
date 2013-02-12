class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :print_rails_env

  private
  def print_rails_env
  	Rails.logger.info "--- Rails Env: #{Rails.env}"
  end
end
