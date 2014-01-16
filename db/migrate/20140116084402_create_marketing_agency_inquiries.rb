class CreateMarketingAgencyInquiries < ActiveRecord::Migration
  def change
    create_table :marketing_agency_inquiries do |t|
      t.string :name
      t.string :company_name
      t.string :phone_number
      t.string :email
      t.timestamps
    end
  end
end
