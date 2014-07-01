# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140701163504) do

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "role"
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "api_request_payloads", :force => true do |t|
    t.string   "uuid"
    t.string   "controller"
    t.string   "action"
    t.integer  "partner_id"
    t.text     "stats"
    t.text     "status"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "filepath",   :limit => 2303
    t.integer  "manager_id"
    t.string   "label"
  end

  add_index "api_request_payloads", ["uuid"], :name => "index_api_request_payloads_on_uuid", :unique => true

  create_table "app_settings", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "authentications", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "account_type"
    t.integer  "account_id"
    t.string   "image_url",    :limit => 1000
  end

  create_table "businesses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "charges", :force => true do |t|
    t.string   "stripe_charge_id"
    t.integer  "created"
    t.boolean  "livemode"
    t.integer  "fee_amount"
    t.text     "description"
    t.string   "dispute"
    t.boolean  "refunded"
    t.boolean  "paid"
    t.integer  "amount"
    t.integer  "card_last4"
    t.integer  "amount_refunded"
    t.string   "stripe_customer_token"
    t.text     "fee_description"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "stripe_plan_token"
    t.string   "stripe_invoice_token"
  end

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "shop_id"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"
  add_index "ckeditor_assets", ["shop_id"], :name => "index_ckeditor_assets_on_shop_id"

  create_table "connection_errors", :force => true do |t|
    t.integer  "user_id"
    t.integer  "shop_id"
    t.text     "error"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "connections", :force => true do |t|
    t.integer  "user_id"
    t.integer  "shop_id"
    t.boolean  "active",           :default => true
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "connected_via"
    t.string   "disconnect_event"
  end

  add_index "connections", ["active", "shop_id", "user_id"], :name => "index_connections_on_active_and_shop_id_and_user_id"
  add_index "connections", ["shop_id", "user_id"], :name => "index_connections_on_shop_id_and_user_id", :unique => true

  create_table "coupon_message_extensions", :force => true do |t|
    t.integer "message_id"
    t.text    "redemption_instructions"
  end

  add_index "coupon_message_extensions", ["message_id"], :name => "index_coupon_message_extensions_on_message_id"

  create_table "coupons", :force => true do |t|
    t.string   "stripe_id"
    t.decimal  "percent_off"
    t.decimal  "amount_off"
    t.string   "currency"
    t.boolean  "livemode"
    t.string   "duration"
    t.string   "redeem_by"
    t.string   "max_redemptions"
    t.string   "times_redeemed"
    t.string   "duration_in_months"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "deleted",            :default => false
  end

  add_index "coupons", ["stripe_id"], :name => "index_coupons_on_stripe_id", :unique => true

  create_table "email_trackings", :force => true do |t|
    t.integer  "manager_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "message_id"
    t.string   "redirect_url"
    t.string   "user_email"
  end

  create_table "file_imports", :force => true do |t|
    t.string   "csv_file"
    t.integer  "manager_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "status"
    t.text     "stats"
    t.string   "label",      :default => "Import"
    t.string   "error"
  end

  create_table "interests", :force => true do |t|
    t.integer  "holder_id"
    t.string   "holder_type"
    t.integer  "business_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "invoice_items", :force => true do |t|
    t.string   "stripe_invoice_item_token"
    t.integer  "amount"
    t.string   "livemode"
    t.string   "proration"
    t.string   "stripe_customer_token"
    t.string   "description"
    t.string   "stripe_invoice_token"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "invoices", :force => true do |t|
    t.integer  "subscription_id"
    t.string   "stripe_customer_token"
    t.string   "stripe_invoice_id"
    t.boolean  "paid_status"
    t.integer  "amount"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "stripe_coupon_token"
    t.string   "stripe_plan_token"
    t.integer  "subtotal"
    t.integer  "total"
    t.integer  "stripe_coupon_percent_off"
    t.integer  "stripe_coupon_amount_off"
    t.string   "description"
  end

  create_table "labels", :force => true do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "active",           :default => true
    t.integer  "survey_answer_id"
  end

  add_index "labels", ["active"], :name => "index_labels_on_active"
  add_index "labels", ["shop_id", "active"], :name => "index_labels_on_shop_id_and_active"
  add_index "labels", ["shop_id", "name"], :name => "index_labels_on_shop_id_and_name", :unique => true

  create_table "locations", :force => true do |t|
    t.string   "street_address1"
    t.string   "street_address2"
    t.string   "city"
    t.integer  "state_id"
    t.integer  "shop_id"
    t.string   "zip"
    t.float    "longitude"
    t.float    "latitude"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "uuid"
    t.string   "state_name"
  end

  add_index "locations", ["uuid"], :name => "index_locations_on_uuid", :unique => true

  create_table "managers", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.integer  "shop_id"
    t.boolean  "owner"
    t.integer  "parent_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "picture"
    t.string   "uuid"
  end

  add_index "managers", ["confirmation_token"], :name => "index_managers_on_confirmation_token", :unique => true
  add_index "managers", ["email"], :name => "index_managers_on_email", :unique => true
  add_index "managers", ["reset_password_token"], :name => "index_managers_on_reset_password_token", :unique => true
  add_index "managers", ["uuid"], :name => "index_managers_on_uuid", :unique => true

  create_table "marketing_agency_inquiries", :force => true do |t|
    t.string   "name"
    t.string   "company_name"
    t.string   "phone_number"
    t.string   "email"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "merchant_apps", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "message_attachments", :force => true do |t|
    t.integer  "message_id"
    t.string   "attachment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "message_attachments", ["message_id"], :name => "index_message_attachments_on_message_id"

  create_table "message_change_notifiers", :force => true do |t|
    t.integer  "message_id"
    t.string   "uuid"
    t.text     "content"
    t.text     "rejection_comment"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "subject"
    t.datetime "send_on"
    t.string   "access_token"
  end

  create_table "message_email_auditors", :force => true do |t|
    t.integer  "message_user_id"
    t.boolean  "delivered"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "message_smtp_id"
    t.boolean  "bounced"
    t.boolean  "complaint"
    t.text     "body"
    t.string   "email_to"
    t.integer  "message_id"
  end

  add_index "message_email_auditors", ["message_id"], :name => "index_message_email_auditors_on_message_id"
  add_index "message_email_auditors", ["message_smtp_id"], :name => "index_message_email_auditors_on_message_smtp_id", :unique => true
  add_index "message_email_auditors", ["message_user_id"], :name => "index_message_email_auditors_on_message_user_id"

  create_table "message_folders", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "message_images", :force => true do |t|
    t.integer  "message_id"
    t.string   "title"
    t.string   "image"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "message_labels", :force => true do |t|
    t.integer  "label_id"
    t.integer  "message_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "message_mail_holders", :force => true do |t|
    t.integer  "message_email_auditor_id"
    t.string   "to"
    t.string   "from"
    t.string   "reply_to"
    t.string   "subject",                  :limit => 1000
    t.string   "content_type"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.text     "headers"
    t.text     "text_part_body"
    t.text     "html_part_body"
  end

  create_table "message_users", :force => true do |t|
    t.integer  "message_id"
    t.integer  "user_id"
    t.integer  "message_folder_id"
    t.boolean  "is_read",            :default => false
    t.boolean  "email_read",         :default => false
    t.boolean  "is_forwarded",       :default => false
    t.datetime "received_at"
    t.boolean  "added_individually", :default => false
    t.string   "uuid"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "opt_out"
    t.boolean  "offer_relevant"
  end

  add_index "message_users", ["message_id", "added_individually"], :name => "index_message_users_on_message_id_and_added_individually"
  add_index "message_users", ["message_id", "user_id"], :name => "index_message_users_on_message_id_and_user_id"
  add_index "message_users", ["user_id", "message_folder_id"], :name => "index_message_users_on_user_id_and_message_folder_id"
  add_index "message_users", ["uuid"], :name => "index_message_users_on_uuid", :unique => true

  create_table "message_visual_properties", :force => true do |t|
    t.integer  "message_id"
    t.integer  "message_visual_section_id"
    t.string   "property_key"
    t.text     "property_value"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "message_visual_properties", ["message_id", "message_visual_section_id"], :name => "join_table_index"

  create_table "message_visual_sections", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "messages", :force => true do |t|
    t.string   "type"
    t.integer  "manager_id"
    t.string   "from"
    t.string   "name"
    t.string   "subject"
    t.text     "content"
    t.string   "state"
    t.datetime "send_on"
    t.boolean  "send_immediately",                 :default => false
    t.integer  "parent_id"
    t.string   "uuid"
    t.text     "fine_print"
    t.datetime "beginning"
    t.datetime "ending"
    t.string   "coupon_code"
    t.string   "type_of_discount"
    t.string   "discount_amount"
    t.boolean  "call_to_action"
    t.boolean  "special_try"
    t.text     "rsvp"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.integer  "survey_id"
    t.boolean  "permanent_coupon"
    t.string   "button_url",       :limit => 2303
    t.string   "button_text",      :limit => 1000
    t.boolean  "make_public"
    t.integer  "template_id"
    t.string   "greeting"
  end

  add_index "messages", ["manager_id", "state", "created_at"], :name => "messages_list_index"
  add_index "messages", ["type", "uuid"], :name => "index_messages_on_type_and_uuid"

  create_table "messages_sections", :force => true do |t|
    t.integer  "message_id"
    t.integer  "section_id"
    t.integer  "position"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "messages_sections", ["message_id", "section_id"], :name => "index_messages_sections_on_message_id_and_section_id"

  create_table "oauth_access_grants", :force => true do |t|
    t.integer  "resource_owner_id", :null => false
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.integer  "expires_in",        :null => false
    t.string   "redirect_uri",      :null => false
    t.datetime "created_at",        :null => false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], :name => "index_oauth_access_grants_on_token", :unique => true

  create_table "oauth_access_tokens", :force => true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        :null => false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], :name => "index_oauth_access_tokens_on_refresh_token", :unique => true
  add_index "oauth_access_tokens", ["resource_owner_id"], :name => "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], :name => "index_oauth_access_tokens_on_token", :unique => true

  create_table "oauth_applications", :force => true do |t|
    t.string   "name",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     :null => false
    t.string   "uid",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      :null => false
    t.string   "secret",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   :null => false
    t.string   "redirect_uri",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             :null => false
    t.datetime "created_at",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               :null => false
    t.datetime "updated_at",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               :null => false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.text     "embed_code"
    t.boolean  "checkmark_icon",           :default => true
    t.boolean  "show_default_optyn_text",  :default => true
    t.text     "custom_text"
    t.integer  "render_choice",            :default => 2
    t.integer  "call_to_action",           :default => 2
    t.integer  "begin_state",              :default => 1
    t.string   "background_color",         :default => "#046D95"
    t.string   "redirect_uri_after_login"
    t.text     "custom_css",               :default => "      #optyn_button_wrapper .optyn-text { \n        float: left; \n        padding-left: 150px; \n        padding-top: 20px; \n        color: white; \n        font-weight: bold; \n        text-align: center; \n        font-family:\"Arial, Verdana\", Arial, sans-serif; \n        font-size: 16px; \n      } \n      #optyn_button_wrapper .optyn-button { }  \n      #close_optyn_button { \n        float: right; \n        font-weight: bold; \n        margin: 0px; \n        padding-right: 30px; \n        padding-top: 20px; \n        color: white; \n        vertical-align: middle; \n      } \n      #close_optyn_button a { \n        color: white; \n        position: absolute; \n        z-index: 100; \n      } \n      #optyn-container { \n        float:left; \n        padding-left: 100px; \n        padding-top: 12px; \n      } \n      #optyn-container form { \n        margin: 0px; \n      } \n      #optyn-container form input[type=\"submit\"] { \n        background: #6BC704; \n        border-radius: 4px; \n        display: inline-block; \n        height: 35px; top: 4px; \n        color: #ffffff; \n        font-size: 15px; \n        border: 1px #304d58; \n        font-weight: bold; \n        padding-left: 10px; \n        padding-right: 10px; \n      } \n      #optyn-container form input:hover[type=\"Submit\"] { \n        background: #80d81c; \n        color: #fff;\n      }  \n      #optyn-container h4 { \n        margin: 0px; \n        color: white; \n      }\n\n      #optyn-email-form { \n        margin: 10px 0; \n      }\n      #optyn-email-form #user_name,\n      #optyn-email-form #user_email {\n        width: 180px;\n        padding: 0 10px;\n        border: solid 2px #d4d4d4;\n        background-color: #fbfbfb;\n        box-shadow: none;\n        color: #333333;\n        min-height: 35px;\n        font-size: 17px;\n        font-weight: 300;\n        line-height: 20px;\n      }\n      #optyn-email-form #user_name,\n      #optyn-email-form #user_email { \n        margin-right: 5px; \n      }\n      #optyn-email-form input:last-child { \n        margin-right: 0; \n      }\n      #optyn-email-form input[type=\"submit\"] {\n        background-color: #64aaef;\n        color: #ffffff;\n        min-height: 35px;\n        font-size: 16px;\n        font-weight: 300;\n        line-height: 20px;\n        border: 0;\n        padding: 5 15 5 15px;\n      }\n      #optyn-email-form input[type=\"submit\"]:hover {\n        background-color: #3691ea;\n      }\n"
    t.text     "label_ids"
    t.boolean  "show_name",                :default => false
    t.boolean  "show_form",                :default => false
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], :name => "index_oauth_applications_on_owner_id_and_owner_type"
  add_index "oauth_applications", ["uid"], :name => "index_oauth_applications_on_uid", :unique => true

  create_table "partner_inquiries", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "company_name"
    t.string   "phone_number"
    t.string   "merchants"
    t.string   "referrer"
    t.text     "comment"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "partners", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "organization"
    t.string   "phone"
    t.boolean  "active",                  :default => true
    t.string   "email",                   :default => "",   :null => false
    t.string   "encrypted_password",      :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "subscription_required",   :default => true
    t.string   "header_background_color"
    t.string   "footer_background_color"
    t.string   "from_email"
  end

  add_index "partners", ["email"], :name => "index_partners_on_email", :unique => true
  add_index "partners", ["reset_password_token"], :name => "index_partners_on_reset_password_token", :unique => true

  create_table "permissions", :force => true do |t|
    t.string   "permission_name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "permissions_users", :force => true do |t|
    t.integer  "permission_id"
    t.integer  "user_id"
    t.boolean  "action"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "permissions_users", ["permission_id", "user_id"], :name => "index_permissions_users_on_permission_id_and_user_id"

  create_table "plans", :force => true do |t|
    t.string   "name"
    t.string   "plan_id"
    t.string   "currency"
    t.integer  "amount"
    t.string   "interval"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "min"
    t.integer  "max"
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "redeem_coupons", :force => true do |t|
    t.integer  "message_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sale_message_extensions", :force => true do |t|
    t.integer "message_id"
    t.text    "redemption_instructions"
  end

  add_index "sale_message_extensions", ["message_id"], :name => "index_sale_message_extensions_on_message_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shop_credits", :force => true do |t|
    t.integer  "shop_id"
    t.integer  "remaining_count"
    t.datetime "begins"
    t.datetime "ends"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "shop_credits", ["shop_id", "begins", "ends"], :name => "index_shop_credits_on_shop_id_and_begins_and_ends", :unique => true

  create_table "shops", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "stype"
    t.text     "description"
    t.string   "logo_img"
    t.string   "business_category"
    t.string   "website"
    t.string   "identifier"
    t.string   "time_zone"
    t.integer  "button_impression_count"
    t.integer  "button_click_count"
    t.boolean  "virtual",                    :default => false
    t.integer  "email_box_impression_count", :default => 0
    t.integer  "email_box_click_count",      :default => 0
    t.integer  "coupon_id"
    t.datetime "discount_end_at"
    t.string   "phone_number",               :default => ""
    t.string   "header_background_color",    :default => "#1791C0"
    t.datetime "deleted_at"
    t.boolean  "pre_added",                  :default => false
    t.integer  "partner_id"
    t.string   "uuid"
    t.string   "footer_background_color",    :default => "#ffffff"
    t.boolean  "affiliate_tracker_pinged",   :default => false
    t.string   "verified_email"
    t.boolean  "ses_verified",               :default => false
  end

  add_index "shops", ["identifier"], :name => "index_shops_on_identifier", :unique => true
  add_index "shops", ["name"], :name => "index_shops_on_name"
  add_index "shops", ["partner_id"], :name => "index_shops_on_partner_id"
  add_index "shops", ["uuid"], :name => "index_shops_on_uuid", :unique => true

  create_table "shortened_urls", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type", :limit => 20
    t.string   "url",                                     :null => false
    t.string   "unique_key", :limit => 10,                :null => false
    t.integer  "use_count",                :default => 0, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "shortened_urls", ["owner_id", "owner_type"], :name => "index_shortened_urls_on_owner_id_and_owner_type"
  add_index "shortened_urls", ["unique_key"], :name => "index_shortened_urls_on_unique_key", :unique => true
  add_index "shortened_urls", ["url"], :name => "index_shortened_urls_on_url"

  create_table "social_profiles", :force => true do |t|
    t.integer  "sp_type"
    t.string   "sp_link"
    t.integer  "shop_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "social_profiles", ["shop_id"], :name => "index_social_profiles_on_shop_id"

  create_table "special_message_extensions", :force => true do |t|
    t.integer "message_id"
    t.text    "redemption_instructions"
  end

  add_index "special_message_extensions", ["message_id"], :name => "index_special_message_extensions_on_message_id"

  create_table "stylesheets", :force => true do |t|
    t.integer  "template_id"
    t.string   "name"
    t.string   "location",    :limit => 1000
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.string   "email"
    t.integer  "plan_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "stripe_customer_token"
    t.integer  "shop_id"
    t.boolean  "active"
  end

  create_table "survey_answers", :force => true do |t|
    t.integer  "survey_question_id"
    t.text     "value"
    t.integer  "user_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "survey_answers", ["created_at"], :name => "index_survey_answers_on_created_at"
  add_index "survey_answers", ["survey_question_id"], :name => "index_survey_answers_on_survey_question_id"

  create_table "survey_questions", :force => true do |t|
    t.integer  "survey_id"
    t.string   "element_type"
    t.text     "label"
    t.text     "values"
    t.string   "default_text"
    t.boolean  "show_label",   :default => true
    t.boolean  "required",     :default => true
    t.integer  "position"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "survey_questions", ["survey_id"], :name => "index_survey_questions_on_survey_id"

  create_table "surveys", :force => true do |t|
    t.string   "title"
    t.boolean  "ready"
    t.integer  "shop_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "surveys", ["shop_id"], :name => "index_surveys_on_shop_id"

  create_table "template_images", :force => true do |t|
    t.string   "image"
    t.string   "title"
    t.integer  "template_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "template_uploads", :force => true do |t|
    t.string   "template_html_file"
    t.integer  "manager_id"
    t.integer  "template_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "name"
  end

  create_table "templates", :force => true do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.boolean  "system_generated", :default => false
    t.text     "html"
    t.text     "structure"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "thumbnail"
    t.string   "uuid"
    t.datetime "deleted_at"
    t.integer  "position"
    t.string   "title"
    t.string   "logo"
  end

  add_index "templates", ["uuid"], :name => "index_templates_on_uuid", :unique => true

  create_table "user_labels", :force => true do |t|
    t.integer  "user_id"
    t.integer  "label_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_labels", ["label_id"], :name => "index_user_labels_on_label_id"
  add_index "user_labels", ["user_id", "label_id"], :name => "index_user_labels_on_user_id_and_label_id"
  add_index "user_labels", ["user_id"], :name => "index_user_labels_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email",                               :default => ""
    t.string   "encrypted_password",                  :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "office_zip_code"
    t.string   "home_zip_code"
    t.string   "gender",                 :limit => 1
    t.date     "birth_date"
    t.string   "picture"
    t.string   "alias"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["alias"], :name => "index_users_on_alias", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
