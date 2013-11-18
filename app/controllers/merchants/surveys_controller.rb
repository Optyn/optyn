class Merchants::SurveysController < Merchants::BaseController
	before_filter :current_survey
	before_filter :survey_actually_created, only: [:show]


	def new
		@survey = Survey.create(:title=>"Dummy Title", :ready=>"false", :shop_id=>current_shop.id )
		#FIXME: change with named url
		redirect_to "/merchants/segments/#{@survey.id}/edit"
	end


	def show
		begin
			@survey = Survey.scoped_by_shop_id(current_shop.id).find(params[:id])
		rescue ActiveRecord::RecordNotFound
			@survey = current_survey
			flash.now[:alert] = "Record Not Found"
		end#end of begin
	end#end of show

	def index
		@list_survey = current_shop.survey
	end

	def edit
		begin
			@survey = Survey.scoped_by_shop_id(current_shop.id).find(params[:id])
		rescue ActiveRecord::RecordNotFound
			@survey = current_survey
			flash.now[:alert] = "Record Not Found"
		end#end of begin
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
			#attr_hash['edit_path'] = edit_merchants_survey_survey_question_path(attr_hash['id'])
			#attr_hash['delete_path'] = merchants_survey_survey_question_path(attr_hash['id'])
			attr_hash['edit_path'] = "/merchants/segments/#{attr_hash[:survey_id]}/segment_questions/#{attr_hash[:id]}/edit"
			attr_hash['delete_path'] = "/merchants/segments/#{attr_hash[:survey_id]}/segment_questions/#{attr_hash[:id]}"
			attr_hash['values'] = ["-"] if attr_hash['values'].blank?
		end
		# binding.pry
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
