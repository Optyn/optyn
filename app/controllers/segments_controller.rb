class SegmentsController < BaseController
  skip_before_filter :authenticate_user!, :redirect_to_account

  def index
    @surveys = current_user.unanswered_surveys
  end

  def show
    @survey, @user = fetch_survey_and_user_from_params
    @survey_questions = @survey.survey_questions
  end

  def save_answers
    @survey, @user = fetch_survey_and_user_from_params
    dummy_survey = Survey.new(@survey.attributes.except('id', 'created_at', 'updated_at'))
    answer_elements = params[:survey][:survey_answers_attributes].sort.collect(&:last)
    dummy_survey.survey_answers_attributes = answer_elements
    answers = dummy_survey.survey_answers

    SurveyAnswer.persist(@user, answers)
    redirect_to segments_path
  end

  private
  def fetch_survey_and_user_from_params
    token = params[:id]
    plain_text = Surveys::Encryptor.decrypt(token)
    email, survey_id = plain_text.split("--")
    user = User.find_by_email(email)
    survey = Survey.find(survey_id)

    if user && !user_signed_in?
      sign_in user
    end

    [survey, user]
  end
end
