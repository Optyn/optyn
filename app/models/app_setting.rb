class AppSetting < ActiveRecord::Base
  attr_accessible :name, :value

  def self.optyn_oauth_client
    find_by_name('optyn_oauth_client')
  end

  def self.optyn_oauth_client_id
    find_by_name('optyn_oauth_client').value
  end
end
