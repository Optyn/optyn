class Merchants::SurveysController < Merchants::BaseController
	before_filter :current_survey
	before_filter :survey_actually_created, only: [:show]

	def show
		#we will need id in params to show
		@survey = current_survey
	end

	def index
		@list_survey = current_shop.survey
	end

	def edit
    	flash.now[:alert] = "Please avoid major changes after publishing. Your customers who have already provided their response will not be prompted again."
	end

	def update
		@survey = current_survey
		@survey.attributes = params[:survey]
		@survey.save!
		redirect_to update_dispatcher
	rescue
		render 'edit'
	end

	def questions
		question_attributes = current_survey.survey_questions.collect(&:attributes)
		
		question_attributes.each do |attr_hash|
			attr_hash['edit_path'] = edit_merchants_survey_survey_question_path(attr_hash['id'])
			attr_hash['delete_path'] = merchants_survey_survey_question_path(attr_hash['id'])
			attr_hash['values'] = ["-"] if attr_hash['values'].blank?
		end

		render json: question_attributes
	end

	def preview
		@survey = current_survey
		@survey_questions = @survey.survey_questions
  end

  def launch
    @survey = current_survey
    @survey.update_attribute(:ready, true)
    redirect_to preview_merchants_survey_path
  end

	private
	def survey_actually_created
		if current_survey.dummy?
			redirect_to edit_merchants_survey_path 
			false
		end
	end

	def update_dispatcher
		if params[:choice] == "draft"
			edit_merchants_survey_path
		elsif params[:choice] == "launch"
			merchants_survey_path
		else
			preview_merchants_survey_path
		end 
	end
end
