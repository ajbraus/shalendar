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

ActiveRecord::Schema.define(:version => 20121009224307) do

  create_table "authentications", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "secret"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "pic_url"
  end

  add_index "authentications", ["uid"], :name => "index_authentications_on_uid", :unique => true
  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "cities", ["name"], :name => "index_cities_on_name"

  create_table "comments", :force => true do |t|
    t.string   "content"
    t.string   "creator"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comments", ["event_id"], :name => "index_comments_on_event_id"

  create_table "email_invites", :force => true do |t|
    t.string   "email"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "inviter_id"
    t.string   "message"
  end

  add_index "email_invites", ["event_id", "email"], :name => "index_invites_on_event_id_and_email", :unique => true
  add_index "email_invites", ["event_id"], :name => "index_invites_on_event_id"

  create_table "events", :force => true do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string   "title"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "user_id"
    t.integer  "min",                       :default => 1
    t.integer  "max",                       :default => 10000
    t.float    "duration"
    t.integer  "inviter_id",                :default => 0
    t.boolean  "tipped",                    :default => false
    t.string   "link"
    t.string   "address"
    t.float    "longitude"
    t.float    "latitude"
    t.boolean  "gmaps"
    t.boolean  "guests_can_invite_friends"
    t.integer  "suggestion_id"
    t.float    "price"
  end

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

  create_table "invitations", :force => true do |t|
    t.integer  "invited_user_id"
    t.integer  "invited_event_id"
    t.integer  "inviter_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "invitations", ["invited_event_id"], :name => "index_invitations_on_invited_event_id"
  add_index "invitations", ["invited_user_id", "invited_event_id"], :name => "index_invitations_on_invited_user_id_and_invited_event_id", :unique => true
  add_index "invitations", ["invited_user_id"], :name => "index_invitations_on_invited_user_id"
  add_index "invitations", ["inviter_id"], :name => "index_invitations_on_inviter_id"

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "toggled",     :default => true
    t.boolean  "confirmed"
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "rsvps", :force => true do |t|
    t.integer  "guest_id"
    t.integer  "plan_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "invite_all_friends", :default => false
  end

  add_index "rsvps", ["guest_id", "plan_id"], :name => "index_rsvps_on_guest_id_and_plan_id", :unique => true
  add_index "rsvps", ["guest_id"], :name => "index_rsvps_on_guest_id"
  add_index "rsvps", ["plan_id"], :name => "index_rsvps_on_plan_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "suggestions", :force => true do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string   "title"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "user_id"
    t.integer  "min",                    :default => 1
    t.integer  "max",                    :default => 10000
    t.float    "duration"
    t.string   "link"
    t.string   "address"
    t.float    "longitude"
    t.float    "latitude"
    t.boolean  "gmaps"
    t.string   "category"
    t.float    "price"
    t.boolean  "family_friendly"
    t.string   "promo_img_file_name"
    t.string   "promo_img_content_type"
    t.integer  "promo_img_file_size"
    t.datetime "promo_img_updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                    :default => "",    :null => false
    t.string   "encrypted_password",       :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "name"
    t.string   "city"
    t.boolean  "terms"
    t.boolean  "require_confirm_follow",   :default => false
    t.boolean  "allow_contact",            :default => true
    t.boolean  "notify_event_reminders",   :default => true
    t.boolean  "post_to_fb_wall",          :default => false
    t.string   "APNtoken"
    t.boolean  "iPhone_user",              :default => false
    t.integer  "GCMdevice_id",             :default => 0
    t.integer  "GCMregistration_id",       :default => 0
    t.boolean  "android_user",             :default => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "time_zone"
    t.integer  "new_invited_events_count", :default => 0
    t.boolean  "vendor",                   :default => false
    t.boolean  "email_comments",           :default => true
    t.boolean  "admin",                    :default => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
