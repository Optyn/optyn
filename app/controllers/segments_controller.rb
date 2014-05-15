class SegmentsController < BaseController

  include DashboardCleaner

  skip_before_filter :authenticate_user!, :redirect_to_account, only: [:show, :save_answers, :default]
  before_filter :fetch_survey_and_user_from_params, :ensure_survey_answered_once, only: [:show, :save_answers, :default]
  around_filter :flush_dashboard_unanswered_surveys, only: [:save_answers]

  def index
    @surveys = current_user.unanswered_surveys
  end

  def show
    @survey_questions = @survey.survey_questions
  end

  def default
    @survey_questions = @survey.survey_questions
    sign_in @user
    render action: :show, layout: params[:no_layout].present? ? false : switch_layout 
  end

  def save_answers
    dummy_survey = Survey.new(@survey.attributes.except('id', 'created_at', 'updated_at'))
    answer_elements = params[:survey][:survey_answers_attributes].sort.collect(&:last)
    dummy_survey.survey_answers_attributes = answer_elements
    answers = dummy_survey.survey_answers
    SurveyAnswer.persist(@user, answers)

    if params[:message_id].present?
      Message.create_response_message(@user.id, params[:message_id])
    end

    if user_signed_in?
      @flush = true
      redirect_to segments_path, notice: "Successfully submitted your feedback"
    else
      render("thankyou", layout: (params[:no_layout].present? ? false : "email_feedback"))
    end
  rescue 
    flash[:error] = "Could not submit the survey. Please try again. If the problem still persists please send an email to support@optyn.com"
    redirect_to segment_path(CGI::escape(params[:id]))
  end

  private
  def fetch_survey_and_user_from_params
    token = params[:id]
    plain_text = Encryptor.decrypt(token)
    email, survey_id = plain_text.split("--")
    user = User.find_by_email(email)
    @user = user.blank? ?  Manager.find_by_email(email) : user
    @survey = Survey.find(survey_id)
  end

  def ensure_survey_answered_once
    if @survey.survey_answers.for_user(@user.id).present?
      if params[:email_survey].present?
        render("thankyou", layout: params[:no_layout] ? false : "email_feedback")
      else
        redirect_to(segments_path, notice: 'Looks like you are trying to take already attempted survey. To save your time we would request to take unattempted ones')
      end
    end
  end
end
