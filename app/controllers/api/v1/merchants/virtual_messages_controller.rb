class Api::V1::Merchants::VirtualMessagesController < ApplicationController
  doorkeeper_for :all
  before_filter :locate_receiver, :locate_shop, :check_active_connection

  def create_virtual
    @virtual_message = VirtualMessage.persist_and_add_to_queue(@shop, @receiver, params[:message])
    render(json: {data: @virtual_message.as_json}, status: :created)
  end

  private
  def locate_receiver
    @receiver = User.find_by_alias(params[:email])
    if params[:email].blank? || @receiver.blank?
      render(json: {data: {errors: ["Could not find the receiver for the message."]}}, status: 410)
      false
    end
  end

  def locate_shop
    @shop = Shop.find_by_name(params[:shop])
    if params[:shop].blank? || @shop.blank?
      render(json: {data: {errors: ["Could not find the shop for the message."]}}, status: 410)
      false
    end
  end

  def check_active_connection
    @connection = @receiver.connections.active.find_by_shop_id(@shop)
    if @connection.blank?
      render(json: {data: {errors: ["A connection between the consumer and shop does not exist. The consumer opted out perhaps."]}}, status: 410)
      false
    end
  end
end
