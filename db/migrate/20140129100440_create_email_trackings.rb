class CreateEmailTrackings < ActiveRecord::Migration
  def change
    create_table :email_trackings do |t|
      t.text :data
      t.references :manager
      t.timestamps
    end
  end
end
