class CategoriesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @category = Category.new
    @category.name = params[:name]
    @category.save
  end

  def destroy
    @category = Category.find_by_id(params[:id])
    @category.destroy
  end
end
