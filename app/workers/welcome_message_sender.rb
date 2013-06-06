class WelcomeMessageSender
 @queue = :devise_queue

  def self.perform(account_type, account_id, password=nil)
    if 'user' == account_type
      user = User.find(account_id)
      DeviseExtendedMailer.welcome_user(user, password).deliver
    else
      manager = Manager.find(account_id)
      DeviseExtendedMailer.welcome_manager(manager).deliver
    end
  end
end
