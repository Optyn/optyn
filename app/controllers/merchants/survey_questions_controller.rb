class Merchants::SurveyQuestionsController < Merchants::BaseController

  layout false

  def new
  	@survey_question = SurveyQuestion.new
    @survey_question.values = [""]
  end

  def create
    survey_id = params[:survey_id]
    survey = Survey.find(survey_id)
    @survey_question = survey.survey_questions.build(params[:survey_question])
    @survey_question.values = (params[:survey_question][:values]).select(&:present?) if !params[:survey_question][:values].blank?
    @survey_question.save!
    head :ok
  rescue ActiveRecord::RecordInvalid
    render 'new', status: :unprocessable_entity
  end

  def edit
    @survey_question = SurveyQuestion.find(params[:id])
    @survey_question.values = [""] if @survey_question.values.blank?
    flash.now[:alert] = "Please avoid any major changes on published surveys. Already answered questions will still show stale data."
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
    # binding.pry
    @survey_question = SurveyQuestion.find(params[:id])
    @survey_question.destroy
    head :ok
  end
end
