class Merchants::SurveysController < Merchants::BaseController
	before_filter :survey_actually_created, only: [:show]


	def new
		@survey = Survey.create(:title=>"Dummy Title", :ready=>"false", :shop_id=>current_shop.id )
		#FIXME: change with named url
		redirect_to "/merchants/segments/#{@survey.id}/edit"
	end


	def show
		@survey = current_shop.surveys.find(params[:id])
	end#end of show

	def index
		@list_survey = current_shop.surveys
	end

	def edit
		@survey = current_shop.surveys.find(params[:id])
  	flash.now[:alert] = "Please avoid major changes after publishing. Your customers who have already provided their response will not be prompted again."
	end

	def update
		binding.pry
		survey_id = params[:id]
		@survey = current_shop.surveys.find(survey_id)
		if params[:choice]=="launch"
			if !is_launch_worthy(@survey)
				return
			end
		end

		@survey.attributes = params[:survey]
		@survey.save!
		redirect_to update_dispatcher
	rescue
		render 'edit'
	end

	def questions
		current_survey = current_shop.surveys.find(params[:id])
		question_attributes = current_survey.survey_questions.collect(&:attributes)
		
		question_attributes.each do |attr_hash|
			##FIXME: replace with named routes
			#attr_hash['edit_path'] = edit_merchants_survey_survey_question_path(attr_hash['id'])
			#attr_hash['delete_path'] = merchants_survey_survey_question_path(attr_hash['id'])
			attr_hash['edit_path'] = "/merchants/segments/#{attr_hash['survey_id']}/segment_questions/#{attr_hash['id']}/edit"
			attr_hash['delete_path'] = "/merchants/segments/#{attr_hash['survey_id']}/segment_questions/#{attr_hash['id']}"
			attr_hash['values'] = ["-"] if attr_hash['values'].blank?
		end
		# binding.pry
		render json: question_attributes
	end

	def preview
		@survey = Survey.scoped_by_shop_id(current_shop.id).find(params[:id])
		@survey_questions = @survey.survey_questions
  end

  def launch
  	survey_id = params[:id]
  	##final check befroe launching survey
    @survey = Survey.scoped_by_shop_id(current_shop.id).find(survey_id)
    survey_questions = @survey.survey_questions
    if survey_questions.present?
	    @survey.update_attribute(:ready, true)
	    redirect_to preview_merchants_survey_path
		else
			flash[:alert] = "No Questions in this survey"
			redirect_to :back
		end
  end

	private
	def survey_actually_created
		@survey = current_shop.surveys.find(params[:id])
		if @survey.dummy?
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

	def is_launch_worthy(survey)
		if survey.survey_questions.present?
			flash[:error] = "No Question present so cant launch"
			return false
		# elsif 				
		end#end of if
	end#end of def

end
