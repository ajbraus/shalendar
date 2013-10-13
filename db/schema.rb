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

ActiveRecord::Schema.define(:version => 20130811212427) do

  create_table "apn_apps", :force => true do |t|
    t.text     "apn_dev_cert"
    t.text     "apn_prod_cert"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "apn_devices", :force => true do |t|
    t.string   "token",              :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "last_registered_at"
    t.integer  "app_id"
  end

  add_index "apn_devices", ["token"], :name => "index_apn_devices_on_token"

  create_table "apn_group_notifications", :force => true do |t|
    t.integer  "group_id",          :null => false
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.text     "custom_properties"
    t.datetime "sent_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "apn_group_notifications", ["group_id"], :name => "index_apn_group_notifications_on_group_id"

  create_table "apn_notifications", :force => true do |t|
    t.integer  "device_id",                        :null => false
    t.integer  "errors_nb",         :default => 0
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.datetime "sent_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.text     "custom_properties"
  end

  add_index "apn_notifications", ["device_id"], :name => "index_apn_notifications_on_device_id"

  create_table "apn_pull_notifications", :force => true do |t|
    t.integer  "app_id"
    t.string   "title"
    t.string   "content"
    t.string   "link"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.boolean  "launch_notification"
  end

  create_table "authentications", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "secret"
    t.string   "pic_url"
    t.string   "city"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "authentications", ["uid"], :name => "index_authentications_on_uid", :unique => true
  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.string   "timezone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "cities", ["name"], :name => "index_cities_on_name"

  create_table "comments", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comments", ["event_id"], :name => "index_comments_on_event_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "events", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "price"
    t.integer  "user_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "visibility",             :default => 2
    t.string   "link"
    t.string   "address"
    t.float    "longitude"
    t.float    "latitude"
    t.boolean  "gmaps",                  :default => false
    t.string   "slug"
    t.string   "fb_id"
    t.boolean  "one_time",               :default => false
    t.string   "short_url"
    t.string   "promo_url"
    t.string   "promo_vid"
    t.boolean  "require_payment"
    t.integer  "city_id"
    t.string   "promo_img_file_name"
    t.string   "promo_img_content_type"
    t.integer  "promo_img_file_size"
    t.datetime "promo_img_updated_at"
  end

  add_index "events", ["fb_id"], :name => "index_events_on_fb_id"
  add_index "events", ["slug"], :name => "index_events_on_slug"

  create_table "gcm_devices", :force => true do |t|
    t.string   "registration_id",    :null => false
    t.datetime "last_registered_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "gcm_devices", ["registration_id"], :name => "index_gcm_devices_on_registration_id", :unique => true

  create_table "gcm_notifications", :force => true do |t|
    t.integer  "device_id",        :null => false
    t.string   "collapse_key"
    t.text     "data"
    t.boolean  "delay_while_idle"
    t.datetime "sent_at"
    t.integer  "time_to_live"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "gcm_notifications", ["device_id"], :name => "index_gcm_notifications_on_device_id"

  create_table "instances", :force => true do |t|
    t.integer  "event_id"
    t.integer  "city_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.float    "duration"
    t.integer  "visibility", :default => 2
    t.boolean  "over",       :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "instances", ["event_id"], :name => "index_instances_on_event_id"

  create_table "invites", :force => true do |t|
    t.integer  "invitee_id"
    t.integer  "inviteable_id"
    t.string   "inviteable_type"
    t.integer  "inviter_id"
    t.integer  "friends_in",      :default => 0
    t.integer  "intros_in",       :default => 0
    t.integer  "randos_in",       :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "invites", ["inviteable_id", "inviteable_type"], :name => "index_invites_on_inviteable_id_and_inviteable_type"
  add_index "invites", ["invitee_id", "inviteable_id", "inviteable_type"], :name => "unique_invites_index", :unique => true
  add_index "invites", ["invitee_id", "inviteable_type"], :name => "index_invites_on_invitee_id_and_inviteable_type"
  add_index "invites", ["inviter_id"], :name => "index_invites_on_inviter_id"

  create_table "outs", :force => true do |t|
    t.integer  "flake_id"
    t.integer  "outable_id"
    t.string   "outable_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "outs", ["flake_id", "outable_id", "outable_type"], :name => "index_outs_on_flake_id_and_outable_id_and_outable_type", :unique => true
  add_index "outs", ["flake_id", "outable_type"], :name => "index_outs_on_flake_id_and_outable_type"
  add_index "outs", ["outable_id", "outable_type"], :name => "index_outs_on_outable_id_and_outable_type"

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.integer  "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id", "status"], :name => "index_relationships_on_follower_id_and_followed_id_and_status"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "rsvps", :force => true do |t|
    t.integer  "guest_id"
    t.integer  "friends_in",    :default => 0
    t.integer  "intros_in",     :default => 0
    t.integer  "randos_in",     :default => 0
    t.boolean  "muted",         :default => false
    t.integer  "rsvpable_id"
    t.string   "rsvpable_type"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "rsvps", ["guest_id", "rsvpable_id", "rsvpable_type"], :name => "index_rsvps_on_guest_id_and_rsvpable_id_and_rsvpable_type", :unique => true
  add_index "rsvps", ["guest_id", "rsvpable_type"], :name => "index_rsvps_on_guest_id_and_rsvpable_type"
  add_index "rsvps", ["rsvpable_id", "rsvpable_type"], :name => "index_rsvps_on_rsvpable_id_and_rsvpable_type"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "email",                   :default => "",    :null => false
    t.string   "encrypted_password",      :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "authentication_token"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.boolean  "admin",                   :default => false
    t.string   "name"
    t.boolean  "terms",                   :default => true
    t.boolean  "email_comments",          :default => true
    t.boolean  "allow_contact",           :default => true
    t.boolean  "follow_up",               :default => true
    t.boolean  "digest",                  :default => true
    t.boolean  "notify_event_reminders",  :default => true
    t.string   "APNtoken"
    t.boolean  "iPhone_user",             :default => false
    t.integer  "GCMdevice_id",            :default => 0
    t.boolean  "android_user",            :default => false
    t.string   "slug"
    t.integer  "friends_count",           :default => 0
    t.integer  "intros_count",            :default => 0
    t.integer  "friended_bys_count",      :default => 0
    t.integer  "city_id"
    t.boolean  "female"
    t.datetime "birthday"
    t.string   "phone_number"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "apn_device_id",           :default => 0
    t.string   "GCMtoken"
    t.string   "background_file_name"
    t.string   "background_content_type"
    t.integer  "background_file_size"
    t.datetime "background_updated_at"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug"

end
