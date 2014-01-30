class EmailTrackingsController < ApplicationController
  def index
    EmailTracking.new.track(params[:token], current_manager.id)
  end
end
