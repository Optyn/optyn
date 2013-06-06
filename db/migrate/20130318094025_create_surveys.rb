class CreateSurveys < ActiveRecord::Migration
	def change
		create_table :surveys do |t|
			t.string   :title
			t.boolean :ready
			t.references :shop

			t.timestamps
		end

		add_index(:surveys, :shop_id)
	end
end
