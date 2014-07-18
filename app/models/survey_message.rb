class SurveyMessage < Message
  attr_accessible :survey_id, :content

  validates :survey_id, presence: true, on: :update
end