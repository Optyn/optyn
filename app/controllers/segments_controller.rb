class SegmentsController < BaseController
  def index
    @surveys = current_user.unanswered_surveys
  end

  def show
   @survey = Survey.find(params[:id])
   @survey_questions = @survey.survey_questions
  end

  def save_answers
    @survey = Survey.find(params[:id])
    dummy_survey = Survey.new(@survey.attributes.except('id', 'created_at', 'updated_at'))
    answer_elements = params[:survey][:survey_answers_attributes].sort.collect(&:last)
    dummy_survey.survey_answers_attributes = answer_elements
    answers = dummy_survey.survey_answers

    SurveyAnswer.persist(current_user, answers)
    redirect_to segments_path
  end
end
