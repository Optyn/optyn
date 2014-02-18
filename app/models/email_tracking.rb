class EmailTracking < ActiveRecord::Base
  attr_accessible :data, :manager_id, :message_id, :redirect_url, :user_email
  serialize :data, Hash

  scope :for_message, ->(message_identifier) { where(message_id: message_identifier) }

  def self.get_message_click_report(message_id)
    all_entries = for_message(message_id)
    result = {}
    all_entries.each do |entry|
      if result[entry.redirect_url].present?
        result[entry.redirect_url]['count'] = result[entry.redirect_url]['count'] + 1
        result[entry.redirect_url]['emails'] << entry.user_email
      else
        result[entry.redirect_url] = { 'count'=>1, 'emails'=>[entry.user_email]}
      end
    end
    result
  end

  def self.consolidated_count(message_identifier)
    for_message(message_identifier).count
  end


  def track(data)
    track_hash = {
      data: data,
      manager_id: data['manager_id'],
      message_id: data['message_id'],
      redirect_url: data[:redirect_url],
      user_email: data['email']
    }
    EmailTracking.create!(track_hash)
  rescue Exception => e
    p "ERROR ==> #{e.message}"
    p "ERROR ==> #{e.backtrace}"
    return false
  end

end
