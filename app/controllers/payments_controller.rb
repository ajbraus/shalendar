class PaymentsController < ApplicationController
  
  def downgrade
    current_user.vendor = false
    if current_user.save
      Notifier.delay.downgrade(v)
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Your account is now a private account" }
        format.js
      end
    end
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

      unless @user.vendor?
        @user.vendor = true
      end

      @event = Event.find_by_id(params[:id]) if params[:id]
      current_user.rsvp!(@event) if @event

      # if @user.vendor?
      #   if @user.save
      #     render :js => "window.location = '/collect_payments'"
      #   else
      #     format.html { redirect_to :back, notice: 'We could not add your credit card at this time. Please review and try again.' }
      #   end
      # else
      if @user.save
        #redirect_to idea_url(@event), notice: "You successfully joined this idea"
        if @event
          render :js => "window.location = '#{idea_path(@event)}'" 
        else
          render :js => "window.location = '#{root_path}'"
        end
      else
        format.html { redirect_to :back, notice: 'We could not add your credit card at this time. Please review and try again.' }
      end
    return
    
    rescue Balanced::BadRequest => ex
      # what exactly went wrong?
      flash[:notice] = "There was an error processing your card details. Please review and try again."
      redirect_to :back
      #puts ex
      #raise
    end

    unless @user.vendor?
      @user.vendor = true
    end

    @card = Balanced::Card.find(card_uri)
    @account = Balanced::Card.find(card_uri).account
    @user.account_uri = @account.uri
    @user.debits_uri = @account.debits_uri
    @user.credit_card_uri = @card.uri

    @event = Event.find_by_id(params[:id]) if params[:id]
    current_user.rsvp!(@event) if @event

    # if @user.vendor?
    #   if @user.save
    #     render :js => "window.location = '/collect_payments'"
    #   else
    #     format.html { redirect_to :back, notice: 'We could not add your credit card at this time. Please review and try again.' }
    #   end
    # else
    if @user.save
      render :js => "window.location = '/'"
    else
      format.html { redirect_to :back, notice: 'We could not add your credit card at this time. Please review and try again.' }
    end
  end

  def self.recurring_billing
    @venues_to_charge = User.all.select { |u| u.vendor? && u.account_uri.present? && u.created_at > Date.today - 1.month }
    @venues_to_charge.each do |v|
      @amount = 2500
      @account = Balanced::Account.find(v.account_uri)
      @account.debit(@amount)
      Notifier.delay.recurring_receipt(v, @amount)
    end
    @venues_to_downgrade = User.all.select { |u| u.vendor? && u.account_uri.blank? }
    @venues_to_downgrade.each do |v|
      v.vendor = false
      if v.save
        Notifier.delay.missing_bank_account(v)
      end
    end
  end
end

###########################################################################
########################## METHODS FOR MARKETPLACE ########################
###########################################################################


#   def confirm_payment
#     @event = Event.find_by_id(params[:id])
#     @card_details = Balanced::Card.find(current_user.credit_card_uri)
#   end

#   def submit_payment
#     @event = Event.find_by_id(params[:id])
#     @buyer = Balanced::Account.find(current_user.account_uri)
#     if @buyer.debit((@event.price * 100).to_s.split('.')[0], :appears_on_statement => "hoos.in - #{@event.title}", :description => "#{@event.title}" )
#       current_user.rsvp!(@event)
#         Notifier.receipt(current_user, @event).deliver
#       respond_to do |format|
#         format.html { redirect_to idea_path(@event), notice: "You Successfully Joined This Idea!"}
#         format.js
#       end
#     end
#   end

#   def self.pay_merchants
#     @paid_events_today = Event.all.where('starts_at' = Date.yesterday and 'requires_payment' = true)
#     @venues_to_credit = []
#     @paid_events_today.each { |e| @venues_to_credit.push(e.user) }
#     @venues_to_credit.each do |v|
#       @events_to_pay = v.events.where('starts_at' = Date.yesterday and 'requires_payment' = true)
#       @amount = @events_to_pay.inject { |acc, e| acc + e.price }
#       begin
#         @balanced_account = Balanced::Account.find(v.account_uri)
#       rescue Balanced::BadRequest => ex
#         # what exactly went wrong?
#         #puts ex
#         raise
#       end
#         @balanced_account.credit(:amount => @amount,
#                                  :description => @event.start_date + " - " + @event.title)
#         Notifier.delay.venue_receipt(v, @events_to_pay, @amount)
#       end
#     end
#   end

#   def new_merchant
#   end

#   def create_merchant
#     @user = current_user
#     @user.phone_number = params[:phone_number]
#     @user.postal_code = params[:postal_code]
#     @user.street_address = params[:street_address]
#     @user.bank_account_uri = params[:uri]
#     @user.credits_uri = params[:credits_uri]
#     @user.account_uri = Balanced::Account.find_by_email(@user.email).uri

#     if @user.save
#       render :js => "window.location = '/'"
#     else
#       format.html { redirect_to :back, notice: 'We could not add merchant services to your account.' }
#     end
#   end

#   def upgrade
#     current_user.vendor = true
#     #upgrade a user to a merchant
#   end

# end