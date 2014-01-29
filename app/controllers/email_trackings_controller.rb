class EmailTrackingsController < ApplicationController
  def index
    EmailTracking.new(params[:token], current_manager.id).track
  end
end
