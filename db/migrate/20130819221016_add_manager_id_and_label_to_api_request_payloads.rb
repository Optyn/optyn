class AddManagerIdAndLabelToApiRequestPayloads < ActiveRecord::Migration
  def change
  	add_column(:api_request_payloads, :manager_id, :integer)
  	add_column(:api_request_payloads, :label, :string)
  end
end
