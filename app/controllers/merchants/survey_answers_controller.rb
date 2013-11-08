class Merchants::SurveyAnswersController < Merchants::BaseController
  include Merchants::SurveyChecker
  include Merchants::LabelSetUpdate

  before_filter :check_for_survey, only: [:index]

  def index
    @paginated_users = SurveyAnswer.paginated_users(current_survey.id, params[:page])
    @users_map = SurveyAnswer.answers_arranged_by_users(current_survey.id, @paginated_users.collect(&:user_id))
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
