class AddSubscriptionRequiredToPartners < ActiveRecord::Migration
  def change
    add_column :partners, :subscription_required, :boolean,:default=>true
    Partner.update_all(:subscription_required=>true)
  end
end
