class EmailTracking < ActiveRecord::Base
  attr_accessible :data, :manager

  def initialize(data, manager_id)
    @data ||= decrypt(data)
    @manager_id ||= manager_id
  end

  def track
  end

  private
  def decrypt
  end
end
