class MessagesController < BaseController
  include Messagecenter::CommonsHelper
  include DashboardCleaner

  before_filter :populate_user_folder_count, :except => [:offer_relevant]

  before_filter :show_my_messages_only, :only => [:show], :except => [:offer_relevant]

  around_filter :flush_message_latest_messages_and_counts, except: [:inbox, :saved, :trash]

  helper_method :registered_action_location

  def inbox
    @inbox_message_users = MessageUser.inbox_messages(current_user, @page)
    set_unread_messages(@inbox_message_users)
    @inbox_messages = @inbox_message_users.collect(&:message).sort { |message1, message2| message1.send_on == message2.send_on ? message1.id <=> message2.id : message2.send_on <=> message1.send_on }
  end

  def saved
    @saved_message_users = MessageUser.saved_messages(current_user, @page)
    @flush = true
    @saved_messages = @saved_message_users.collect(&:message).sort { |message1, message2| message1.send_on == message2.send_on ? message1.id <=> message2.id : message2.send_on <=> message1.send_on }
  end

  def trash
    @trash_message_users = MessageUser.trash_messages(current_user, @page)
    @flush = true
    @trash_messages = @trash_message_users.collect(&:message).sort { |message1, message2| message1.send_on == message2.send_on ? message1.id <=> message2.id : message2.send_on <=> message1.send_on }
  end

  def show
    @user = current_user
    if !@message_user.blank? && !@message_user.is_read
      @flush = true
      @message_user.update_attribute(:is_read, true)
      populate_user_folder_count(true)
    end
    @shop = @message.manager.shop
    @partner = @shop.partner
  end

  def move_to_inbox
    @messages = Message.for_uuids(uuids_from_message_ids)
    MessageUser.mark_inbox(@messages, [current_user])
    populate_user_folder_count(true)
    @flush = true
    redirect_to inbox_messages_path
  end

  def move_to_trash
    @messages = Message.for_uuids(uuids_from_message_ids)
    MessageUser.mark_deleted(@messages, [current_user])
    populate_user_folder_count(true)
    @flush = true
    redirect_to inbox_messages_path
  end

  def move_to_saved
    @messages = Message.for_uuids(uuids_from_message_ids)
    MessageUser.mark_saved(@messages, [current_user])
    populate_user_folder_count(true)
    @flush = true
    redirect_to saved_messages_path
  end

  def discard
    @messages = Message.for_uuids(uuids_from_message_ids)
    MessageUser.mark_discarded(@messages, [current_user])
    populate_user_folder_count(true)
    @flush = true
    redirect_to inbox_messages_path
  end

  def offer_relevant
    @message_user = MessageUser.for_uuid(params[:message_user_id])
    if !@message_user.blank?
      @message_user.update_attribute(:offer_relevant, params[:offer_relevant])
      @message_user.save
    end
    render "thankyou", layout: "email_feedback"
  end

  private
  def populate_user_folder_count(force=false)
    @inbox_count = MessageUser.cached_user_inbox_count(current_user, force)
  end

  def show_my_messages_only
    @message = Message.for_uuid(params[:id])
    @message_user = @message.message_user(current_user)
    if @message_user.blank?
      redirect_to(inbox_messages_path)
      false
    end
  end

  def registered_action_location
    eval("#{registered_action}_messages_path(:page => #{@page || 1})")
  end

  def set_unread_messages(message_users)
    message_users.each do |message_user|
      unless message_user.is_read
        message_user.message.unread = true
      end
    end
  end
end
