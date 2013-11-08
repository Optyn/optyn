class CreateSocialProfiles < ActiveRecord::Migration
  def change
    create_table :social_profiles do |t|
      t.integer :sp_type
      t.string :sp_link
      t.references :shop

      t.timestamps
    end
    add_index :social_profiles, :shop_id
  end
end
