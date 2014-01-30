class EmailTracking < ActiveRecord::Base
  attr_accessible :data, :manager_id
  serialize :data, Hash

  def track(data)
    track_hash = {
      data: data,
      manager_id: data[:manager_id]
    }
    EmailTracking.create!(track_hash)
    rescue Exception => e
    p "ERROR ==> #{e.message}"
    p "ERROR ==> #{e.backtrace}"
    return false
  end
end
