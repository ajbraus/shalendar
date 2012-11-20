class PaymentsController < ApplicationController
  def confirm_payment
    @event = Event.find_by_id(params[:id])
    @user = current_user
    @card_details = Balanced::Card.find(current_user.credit_card_uri)
    @name = @card_details.name
    @last_four = @card_details.last_four
  end

  def submit_payment(event)
    @event = event
    current_user.debit!(@event.price)
    current_user.rsvp!(@event)
  end

  def new_card
    @event = Event.find_by_id(params[:id]) if params[:id]
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
      # unless ex.category_code == 'duplicate-email-address'
      #   raise
      # end
      # notice extras? it includes some helpful additionals.
      # puts "This account already exists on Balanced! Here it is #{ex.extras[:account_uri]}"
      @account = Balanced::Account.find ex.extras[:account_uri]
      @account.add_card card_uri
      @user.account_uri = @account.uri
      @user.debits_uri = @account.debits_uri
      @user.credit_card_uri = card_uri

      @event = Event.find_by_id(params[:id]) if params[:id]
      current_user.rsvp!(@event) if @event

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
    return
    
    rescue Balanced::BadRequest => ex
      # what exactly went wrong?
      flash[:notice] = "There was an error processing your card details. Please review and try again."
      redirect_to :back
      #puts ex
      #raise
    end

    @card = Balanced::Card.find(card_uri)
    @account = Balanced::Card.find(card_uri).account
    @user.account_uri = @account.uri
    @user.debits_uri = @account.debits_uri
    @user.credit_card_uri = @card.uri

    @event = Event.find_by_id(params[:id]) if params[:id]
    current_user.rsvp!(@event) if @event

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

  def self.recurring_billing
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
    @user.account_uri = Balanced::Account.find_by_email(@user.email).uri

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