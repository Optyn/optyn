class CreatePartnerInquiries < ActiveRecord::Migration
  def change
    create_table :partner_inquiries do |t|
      t.string :name
      t.string :email
      t.string :company_name
      t.string :phone_number
      t.string :merchants
      t.string :referrer
      t.text :comment

      t.timestamps
    end
  end
end
