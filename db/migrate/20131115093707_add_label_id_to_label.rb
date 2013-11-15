class AddLabelIdToLabel < ActiveRecord::Migration
  def change
    add_column :labels, :survey_answer_id, :integer
  end
end
