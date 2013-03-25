class SurveyAnswer < ActiveRecord::Base
  belongs_to :survey_question

  attr_accessible :survey_question_id, :value, :user_id
  serialize :values, Array

  scope :includes_surveys, includes(survey_question: :survey)

  scope :for_user, ->(user_id) { where(user_id: user_id) }

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
end
