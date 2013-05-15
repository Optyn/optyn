class DashboardsController < ApplicationController
  def index
    @pending_survey_count = current_user.unanswered_surveys_count
  end
end