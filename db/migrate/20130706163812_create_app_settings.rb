class CreateAppSettings < ActiveRecord::Migration
  def change
    create_table :app_settings do |t|
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
