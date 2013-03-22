class CreateSurveyQuestions < ActiveRecord::Migration
	def change
		create_table :survey_questions do |t|
			t.references :survey
			t.string   :element_type
			t.text     :label
			t.text     :values
			t.string   :default_text
			t.boolean  :show_label,       default:  true
			t.boolean  :required,         default:  true
			t.integer  :position

			t.timestamps
		end
		add_index(:survey_questions, :survey_id)
	end
end
