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

ActiveRecord::Schema.define(:version => 20130418143022) do

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

  create_table "authentications", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "account_type"
    t.integer  "account_id"
  end

  create_table "businesses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "connections", :force => true do |t|
    t.integer  "user_id"
    t.integer  "shop_id"
    t.boolean  "active",        :default => true
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "connected_via"
  end

  add_index "connections", ["shop_id", "user_id"], :name => "index_connections_on_shop_id_and_user_id", :unique => true

  create_table "interests", :force => true do |t|
    t.integer  "holder_id"
    t.string   "holder_type"
    t.integer  "business_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "labels", :force => true do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "active",     :default => true
  end

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
  end

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
  end

  add_index "managers", ["confirmation_token"], :name => "index_managers_on_confirmation_token", :unique => true
  add_index "managers", ["email"], :name => "index_managers_on_email", :unique => true
  add_index "managers", ["reset_password_token"], :name => "index_managers_on_reset_password_token", :unique => true

  create_table "message_attachments", :force => true do |t|
    t.integer  "message_id"
    t.string   "attachment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "message_attachments", ["message_id"], :name => "index_message_attachments_on_message_id"

  create_table "message_email_auditors", :force => true do |t|
    t.integer  "message_user_id"
    t.boolean  "delivered"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "message_folders", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "message_labels", :force => true do |t|
    t.integer  "label_id"
    t.integer  "message_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "message_users", ["message_id", "added_individually"], :name => "index_message_users_on_message_id_and_added_individually"
  add_index "message_users", ["message_id", "user_id"], :name => "index_message_users_on_message_id_and_user_id"
  add_index "message_users", ["user_id", "message_folder_id"], :name => "index_message_users_on_user_id_and_message_folder_id"

  create_table "messages", :force => true do |t|
    t.string   "type"
    t.integer  "manager_id"
    t.string   "from"
    t.string   "name"
    t.string   "second_name"
    t.string   "subject"
    t.text     "content"
    t.string   "state"
    t.datetime "send_on"
    t.boolean  "send_immediately", :default => false
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
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "messages", ["manager_id", "state", "created_at"], :name => "messages_list_index"
  add_index "messages", ["type", "uuid"], :name => "index_messages_on_type_and_uuid"

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
    t.string   "name",         :null => false
    t.string   "uid",          :null => false
    t.string   "secret",       :null => false
    t.string   "redirect_uri", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], :name => "index_oauth_applications_on_owner_id_and_owner_type"
  add_index "oauth_applications", ["uid"], :name => "index_oauth_applications_on_uid", :unique => true

  create_table "permissions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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

  create_table "shops", :force => true do |t|
    t.string   "name"
    t.text     "embed_code"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "stype"
    t.string   "description"
    t.string   "logo_img"
    t.string   "business_category"
    t.string   "website"
    t.string   "identifier"
    t.string   "time_zone"
  end

  add_index "shops", ["identifier"], :name => "index_shops_on_identifier", :unique => true

  create_table "states", :force => true do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
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

  create_table "user_labels", :force => true do |t|
    t.integer  "user_id"
    t.integer  "label_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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
    t.boolean  "zip_prompted"
    t.string   "gender",                 :limit => 1
    t.date     "birth_date"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
