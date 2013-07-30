class CreateApiRequestPayloads < ActiveRecord::Migration
  def change
    create_table :api_request_payloads do |t|
      t.string :uuid
      t.string :controller
      t.string :action
      t.references :partner
      t.text :body
      t.text :stats
      t.text :status

      t.timestamps
    end

    add_index(:api_request_payloads, :uuid, unique: true)
  end
end
