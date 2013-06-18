class SurveyMessage < Message
  attr_accessible :survey_id

  validates :survey_id, presence: true
end