class Merchants::SurveyAnswersController < Merchants::BaseController
  include Merchants::SurveyChecker

  before_filter :check_for_survey

  def index
    @users_map = SurveyAnswer.answers_arranged_by_users(current_survey.id)
  end
end
