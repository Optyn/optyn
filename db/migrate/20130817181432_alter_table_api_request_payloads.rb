class AlterTableApiRequestPayloads < ActiveRecord::Migration
  def up
  	add_column(:api_request_payloads, :filepath, :string, limit: 2303)
  	remove_column(:api_request_payloads, :body)
  end

  def down
  	remove_column(:api_request_payloads, :filepath)
  	add_column(:api_request_payloads, :body, :text)
  end
end
