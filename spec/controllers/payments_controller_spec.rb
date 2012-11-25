require 'spec_helper'

describe PaymentsController do
	use_vcr_cassette
  before do
    api_key = Balanced::ApiKey.new.save
    Balanced.configure api_key.secret
    @marketplace = Balanced::Marketplace.new.save
  end
	
	describe "create a new card" do
		before do 
			# @card = Balanced::Card.new(
   #      :card_number => "4111111111111111",
   #      :expiration_month => "12",
   #      :expiration_year => "2015",
   #    ).save
   #    @buyer = Balanced::Account.new(
   #      :uri => @marketplace.accounts_uri,
   #      :email_address => "buyer7@example.org",
   #      :card_uri => @card.uri,
   #      :name => "Jack Q Buyer"
   #    ).save
		end
		it "should create a new card" do

		end
	end

	describe "recurring billing" do
		it "should bill the venues monthly" do 

		end
	end

	describe "downgrade" do 
		it "should downgrade an account from venue to private" do

		end
	end
end

