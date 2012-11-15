class PaymentsController < ApplicationController
  def new_card

  end

  def create_card
    @user = current_user
    card_uri = params[:uri]
    email_address = 'buyer@example.org'

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

  def debit
  end

  def credit
  end

  def refund
  end

  def recurring_billing
    #something like this!
    for account in db.query.accounts.all():
      balanced_account = Balanced.Account.find(account.balanced_account_uri)
      balanced_account.debit(amount=account.monthly_charge)
    end
  end


  def new_merchant
    @user = current_user
  end

  def create_merchant
    @user = current_user
    @user.update_attributes(params)
    @user.bank_account = true
    respond_to do |format|
      if @user.save
        format.html { redirect_to root_path, notice: 'You may now collect payments with hoos.in' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { redirect_to :back, notice: 'We could not add merchant services to your account.') }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end 
  end

end