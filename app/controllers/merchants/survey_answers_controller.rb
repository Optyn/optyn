class Merchants::SurveyAnswersController < Merchants::BaseController
  include Merchants::LabelSetUpdate

  def select_survey
    @list_survey = Survey.where(:shop_id => current_shop.id)
  end 

  def index
    @paginated_users = SurveyAnswer.paginated_users(params[:survey_id], params[:page])
    @users_map = SurveyAnswer.answers_arranged_by_users(params[:survey_id], @paginated_users.collect(&:user_id))
    populate_labels
  end

  def create_label
    create_label_helper_method_called
  end

  def update_labels
    update_labels_helper_method_called
  end

  private
  def populate_labels
    @names = current_shop.labels.active
  end
end
