class EmailTracking < ActiveRecord::Base
  attr_accessible :data, :manager
  serialize :data, Hash

  def track(token, manager_id)
    data = decrypt(token)
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

  private
  def decrypt(token)
    Encryptor.decrypt_for_template(token)
    rescue Exception => e
    p "ERROR ==> #{e.message}"
    p "ERROR ==> #{e.backtrace}"
    return token
  end
end
