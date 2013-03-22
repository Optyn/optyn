class Survey < ActiveRecord::Base
	belongs_to :shop
	has_many :survey_questions, order: "CASE WHEN survey_questions.position IS NULL THEN 999 ELSE survey_questions.position END, survey_questions.id", dependent: :destroy 

  has_many :survey_answers, order: "survey_answers.created_at", :through => :survey_questions

  attr_accessible :title, :ready

  accepts_nested_attributes_for :survey_questions, allow_destroy: true

  def dummy?
  	!(title.present?)
  end

  def ready_text
  	ready ? "Yes" : "No"
  end
end
