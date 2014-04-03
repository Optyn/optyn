class EmailTracking < ActiveRecord::Base
  attr_accessible  :manager_id, :message_id, :redirect_url, :user_email

  scope :for_message, ->(message_identifier) { where(message_id: message_identifier) }
 # To be refactored needs to be done with querery
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
    email_tracking = EmailTracking.where("message_id = ? and user_email = ? and redirect_url = ? ", data['message_id'], data['email'], data[:redirect_url])
    if !email_tracking.present?
      track_hash = {
        manager_id: data['manager_id'],
        message_id: data['message_id'],
        redirect_url: data[:redirect_url],
        user_email: data['email']
      }
    EmailTracking.create!(track_hash)
  end
  rescue Exception => e
    p "ERROR ==> #{e.message}"
    p "ERROR ==> #{e.backtrace}"
    return false
  end

end
