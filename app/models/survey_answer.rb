class SurveyAnswer < ActiveRecord::Base
  belongs_to :survey_question
  belongs_to :user

  attr_accessible :survey_question_id, :value, :user_id
  serialize :value, Array

  scope :includes_surveys, includes(survey_question: :survey)

  scope :includes_question, includes(:survey_question)

  scope :includes_user, includes(:user)

  scope :for_user, ->(user_id) { where(user_id: user_id) }

  scope :for_survey, ->(survey_id){includes_surveys.where(["surveys.id = :survey_id", survey_id: survey_id])}

  scope :created_backwords, order("survey_answers.created_at DESC")

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

  def self.answers_arranged_by_users(survey_id)
    answers = for_survey(survey_id).include_user.created_backwords

    user_ids = answers.collect(&:user_id)
    users_hash = ActiveSupport::OrderedHash.new

    user_ids.each {|user_id| users_hash[user_id] = []}

    answers.each do |answer|
      users_hash[answer.user_id] << answer
    end

    users_hash
  end

  def question
    survey_question.label
  end
end
