class AddSurveyIdToMessages < ActiveRecord::Migration
  def change
    add_column(:messages, :survey_id, :integer)
  end
end
