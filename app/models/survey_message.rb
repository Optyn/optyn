class SurveyMessage < Message
  attr_accessible :fine_print, :survey_id

  validates :survey_id, presence: true
end