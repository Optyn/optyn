class SurveyAnswer < ActiveRecord::Base
  belongs_to :survey_question
  belongs_to :user

  delegate :survey, to: :survey_question

  attr_accessible :survey_question_id, :value, :user_id
  serialize :value, Array

  PAGE = 1
  PER_PAGE = 50

  scope :includes_surveys, includes(survey_question: :survey)

  scope :includes_question, includes(:survey_question)

  scope :includes_user, includes(:user)

  scope :joins_user, joins(:user)

  scope :for_user, ->(user_id) { where(user_id: user_id) }

  scope :joins_surveys, joins(survey_question: :survey)

  scope :for_survey_with_joins, ->(survey_id){joins_surveys.where(["surveys.id = :survey_id", survey_id: survey_id])}

  scope :for_survey_with_inclusion, ->(survey_id){includes_surveys.where(["surveys.id = :survey_id", survey_id: survey_id])}

  scope :created_backwords, order("\"survey_answers\".created_at DESC")

  scope :uniq_users, ->(survey_id){for_survey(survey_id).pluck(:user_id).uniq}

  scope :group_by_user, group("survey_answers.user_id")

  def self.uniq_shop_ids(user_id)
    for_user(user_id).includes_surveys.collect(&:survey_question).collect(&:survey).collect(&:shop_id).uniq
  end

  def self.persist(current_user, answers)
    SurveyAnswer.transaction do
      answers.each do |answer|
        answer.user_id = current_user.id
        answer.save!
      end
    end

  end

  def self.paginated_users(survey_id, page_number=PAGE, per_page=PER_PAGE)
    select('DISTINCT(survey_answers.user_id), survey_answers.created_at').for_survey_with_joins(survey_id).created_backwords.page(page_number).per(per_page)
  end


  def self.answers_arranged_by_users(survey_id, user_ids)
    answers = for_survey_with_inclusion(survey_id).for_user(user_ids).includes_user.created_backwords

    user_ids = answers.collect(&:user_id)
    users_hash = ActiveSupport::OrderedHash.new

    user_ids.each {|user_id| users_hash[user_id] = []}

    answers.each do |answer|
      users_hash[answer.user_id] << answer
    end
    users_hash
  end

  def self.users(shop_id, survey_id, limit_count = SiteConfig.dashboard_limit, force = false)
    cache_key = "dashboard-recent-surveys-shop-#{shop_id}"
    Rails.cache.fetch(cache_key, force: force, expires_in: SiteConfig.ttls.dashboard_count) do
      answers = select("users.id, users.name AS user_name, AVG(EXTRACT(EPOCH FROM survey_answers.created_at)) as ts").group("users.id").for_survey_with_joins(survey_id).order("ts").joins_user.limit(limit_count).all
      answers.collect{|answer| [answer['user_name'], answer['ts']]}
    end
  end

  def question
    survey_question.label
  end
end
