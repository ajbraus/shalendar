class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Token authenticatable
      t.string :authentication_token


      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :authentication_token, :unique => true
    # add_index :users, :unlock_token,         :unique => true

    add_column :users, :admin, :boolean, default: false
    add_column :users, :name, :string
    add_column :users, :terms, :boolean, default: true
    add_column :users, :email_comments, :boolean, default: true
    add_column :users, :allow_contact, :boolean, default: true
    add_column :users, :follow_up, :boolean, default: true
    add_column :users, :digest, :boolean, default: true
    add_column :users, :notify_event_reminders, :boolean, :default => true
    add_column :users, :APNtoken, :string
    add_column :users, :iPhone_user, :bool, :default => false
    add_column :users, :GCMdevice_id, :integer, default: 0
    add_column :users, :GCMregistration_id, :integer, default: 0
    add_column :users, :android_user, :bool, default: false
    add_column :users, :slug, :string
    add_column :users, :friends_count, :integer, default: 0
    add_column :users, :intros_count, :integer, default: 0
    add_column :users, :friended_bys_count, :integer, default: 0
    add_column :users, :city_id, :integer
    add_column :users, :female, :boolean
    add_column :users, :birthday, :datetime
    add_column :users, :phone_number, :string #E.164 formatted phone number. Length must be <= 15. "+16505551234"

    # add_column :users, :street_address, :string
    # add_column :users, :postal_code, :string
    # add_column :users, :country, :string #ISO-3166-3 three character country code.
    # add_column :users, :account_uri, :string
    # add_column :users, :bank_account_uri, :string
    # add_column :users, :credits_uri, :string
    # add_column :users, :credit_card_uri, :string
    # add_column :users, :debits_uri, :string
    
    add_index :users, :slug
  end
end
