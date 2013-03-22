class CreateSurveyAnswers < ActiveRecord::Migration
	def change
		create_table :survey_answers do |t|
			t.references :survey_question
			t.text       :value
			t.references :user

			t.timestamps
		end

		add_index(:survey_answers, :survey_question_id)
		add_index(:survey_answers, :created_at)
	end
end
