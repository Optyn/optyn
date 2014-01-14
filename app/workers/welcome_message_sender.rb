class WelcomeMessageSender
  include Sidekiq::Worker
  sidekiq_options :queue => :general_queue, :backtrace => true
 # @queue = :general_queue

  def perform(account_type, account_id, password=nil, shop_id=nil)
    if 'user' == account_type
      user = User.find(account_id)
      DeviseExtendedMailer.welcome_user(user, password, shop_id).deliver
    else
      manager = Manager.find(account_id)
      DeviseExtendedMailer.welcome_manager(manager).deliver
    end
  end
end
