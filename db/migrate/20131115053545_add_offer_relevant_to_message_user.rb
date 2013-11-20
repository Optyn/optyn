class AddOfferRelevantToMessageUser < ActiveRecord::Migration
  def change
    add_column :message_users, :offer_relevant, :boolean
  end
end
