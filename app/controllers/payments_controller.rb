class PaymentsController < ApplicationController
  def new_card
  end

  def create_card
    @user = current_user
    card_uri = params[:uri]
    email_address = @user.email

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
      # puts "This account already exists on Balanced! Here it is #{ex.extras[:account_uri]}"
      buyer = Balanced::Account.find ex.extras[:account_uri]
      buyer.add_card card_uri
    rescue Balanced::BadRequest => ex
      # what exactly went wrong?
      puts ex
      raise
    end
    
    @card = Balanced::Card.find(params[:uri])
    @account = Balanced::Card.find(params[:uri]).account
    @user.account_uri = @account.uri
    @user.debits_uri = @account.debits_uri
    @user.credit_card_uri = @card.uri

    if @user.vendor?
      if @user.save
        render :js => "window.location = '/collect_payments'"
      else
        format.html { redirect_to :back, notice: 'We could not add your credit card at this time. Please review and try again.' }
      end
    else
      if @user.save
        render :js => "window.location = '/'"
      else
        format.html { redirect_to :back, notice: 'We could not add your credit card at this time. Please review and try again.' }
      end
    end
  end

  def recurring_billing
    #something like this!
    for account in db.query.accounts.all()
      balanced_account = Balanced.Account.find(account.balanced_account_uri)
      balanced_account.debit(amount=account.monthly_charge)
    end
  end


  def new_merchant
  end

  def create_merchant
    @user = current_user
    @user.phone_number = params[:phone_number]
    @user.postal_code = params[:postal_code]
    @user.street_address = params[:street_address]
    @user.bank_account_uri = params[:uri]
    @user.credits_uri = params[:credits_uri]
    @user.account_uri = Balanced::Account.find_by_email(@user.email)

    if @user.save
      render :js => "window.location = '/'"
    else
      format.html { redirect_to :back, notice: 'We could not add merchant services to your account.' }
    end
  end

  def upgrade
    @user = current_user
    #upgrade a user to a merchant
  end

end