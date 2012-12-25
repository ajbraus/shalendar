class CategorizationsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @categorization = current_user.categorizations.create(category_id: params[:category_id])
    
    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end

  def destroy
    @categorization = current_user.categorizations.find_by_category_id(params[:category_id])
    @categorization.destroy

    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end
end