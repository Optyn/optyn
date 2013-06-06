module Merchants
  module SurveyChecker
    private
    def check_for_survey
      redirect_to merchants_survey_path unless current_survey.present?
    end
  end
end