class Merchants::SurveyQuestionsController < Merchants::BaseController
  include Merchants::SurveyChecker

  layout false

  before_filter :check_for_survey

  def new
  	@survey_question = SurveyQuestion.new
    @survey_question.values = [""]
  end

  def create
    @survey_question = current_survey.survey_questions.build(params[:survey_question])
    @survey_question.values = (params[:survey_question][:values]).select(&:present?)
    @survey_question.save!
    head :ok
  rescue ActiveRecord::RecordInvalid
    render 'new', status: :unprocessable_entity
  end

  def edit
    @survey_question = SurveyQuestion.find(params[:id])
    @survey_question.values = [""] if @survey_question.values.blank?
  end

  def update
    @survey_question = SurveyQuestion.find(params[:id])
    @survey_question.attributes = params[:survey_question]
    @survey_question.values = (params[:survey_question][:values]).select(&:present?)
    @survey_question.save!
    head :ok
  rescue ActiveRecord::RecordInvalid
    render 'edit', status: :unprocessable_entity
  end

  def destroy
    @survey_question = SurveyQuestion.find(params[:id])
    @survey_question.destroy
    head :ok
  end
end
