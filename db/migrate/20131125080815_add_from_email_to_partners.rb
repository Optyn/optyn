class AddFromEmailToPartners < ActiveRecord::Migration
  def change
    add_column(:partners, :from_email, :string, index: true)
  end
end
