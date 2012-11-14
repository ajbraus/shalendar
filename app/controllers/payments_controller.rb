class PaymentsController < ApplicationController
	def debit
	end

	def credit
	end

	def refund
	end

  def create_buyer
    card_uri = params[:uri]
    email_address = current_user.email

    # for a new account
    begin
      buyer = Balanced::Marketplace.my_marketplace.create_buyer(
          email_address,
          card_uri)
    rescue Balanced::Conflict => ex
      unless ex.category_code == 'duplicate-email-address'
        raise
      end
      # notice extras? it includes some helpful additionals.
      puts "This account already exists on Balanced! Here it is #{ex.extras[:account_uri]}"
      buyer = Balanced::Account.find ex.extras[:account_uri]
      buyer.add_card card_uri
    rescue Balanced::BadRequest => ex
      # what exactly went wrong?
      puts ex
      raise
    end
  end

  def create_merchant
    bank_account = Balanced::BankAccount.new(
    :account_number => "1234567890",
    :bank_code => "321174851",
    :name => "Jack Q Merchant",
    :type => "checking",
    ).save

    begin
      merchant = Balanced::Marketplace.my_marketplace.create_merchant(
          "merchant@example.org",
          {
            :type => "person",
            :name => "Billy Jones",
            :street_address => "801 High St.",
            :postal_code => "99999",
            :country => "USA",
            :phone_number => "+16505551234",
          },
          bank_account.uri,
          "Jack Q Merchant",
      )
    rescue Balanced::Conflict => ex
      # handle the conflict here..
    rescue Balanced::BadRequest => ex
      # prompt for fix, then retry
    rescue Balanced::MoreInformationRequired => ex
      redirect_to ex.redirect_uri + '?redirect_uri=' + after_redirection
    end
  end
end