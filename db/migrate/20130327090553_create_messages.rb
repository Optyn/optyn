class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :type
      t.references :manager
      t.string :from
      t.string :name    #campaign name
      t.string :subject #Subject line of the marketing message
      t.text :content #details
      t.string :state
      t.datetime :send_on
      t.boolean :send_immediately, :default => false
      t.boolean :parent_id

      #template attributes
      t.text :fine_print #Coupon, Special
      t.datetime :beginning_date #Special, SpecialAnnouncement
      t.datetime :ending_date #Special, SpecialAnnouncement
      #image??

      #Cupon
      t.string :coupon_code
      t.string :type_of_discount
      t.string :discount_amount
      t.string :coupon_code

      #Announcement
      t.boolean :call_to_action

      #Product
      t.boolean :special_try

      #Event
      t.text :rsvp

      t.timestamps
    end

    add_index :messages, [:manager_id, :state, :created_at], :name => "messages_list_index"
  end
end
