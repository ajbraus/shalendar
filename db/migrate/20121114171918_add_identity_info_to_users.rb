class AddIdentityInfoToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :type, :string
  	add_column :users, :street_address, :string
  	add_column :users, :postal_code, :string
  	add_column :users, :country, :string #ISO-3166-3 three character country code.
  	add_column :users, :phone_number, :string #E.164 formatted phone number. Length must be <= 15. "+16505551234"
  	add_column :users, :account_uri, :string
  	add_column :users, :bank_account_uri, :string
    add_column :users, :credits_uri, :string
  	add_column :users, :credit_card_uri, :string
    add_column :users, :debits_uri, :string
    add_column :events, :require_payment, :boolean
  end
end
