class Merchants::SurveyAnswersController < Merchants::BaseController
  include Merchants::SurveyChecker

  before_filter :check_for_survey, only: [:index]

  def index
    @paginated_users = SurveyAnswer.paginated_users(current_survey.id, params[:page])
    @users_map = SurveyAnswer.answers_arranged_by_users(current_survey.id, @paginated_users.collect(&:user_id))
    populate_labels
  end

  def create_label
    existing_label = current_shop.labels.find_by_name(params[:label].strip)
    label = current_shop.labels.create(name: params[:label].strip) unless existing_label.present?
    ref_label = existing_label.present? ? existing_label : label
    user_label = UserLabel.find_or_create_by_user_id_and_label_id(user_id: params[:user_id], label_id: ref_label.id)

    render json: (label.attributes.except('shop_id', 'created_at', 'updated_at') rescue []).to_json
  end

  def update_labels
    user = User.find(params[:user_id])
    label_ids = params[:label_ids].collect(&:to_i) rescue []
    user.adjust_labels(label_ids)
    render nothing: true
  end

  private
  def populate_labels
    @names = current_shop.labels.active
  end
end
