class PaymentsController < ApplicationController
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