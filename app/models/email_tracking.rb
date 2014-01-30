class EmailTracking < ActiveRecord::Base
  attr_accessible :data, :manager
  serialize :data, Hash

  def track(data, manager_id)
    track_hash = {
      data: data,
      manager_id: manager_id
    }
    et = EmailTracking.new(track_hash)
    et.save
    rescue Exception => e
    p "ERROR ==> #{e.message}"
    p "ERROR ==> #{e.backtrace}"
    return false
  end
end
