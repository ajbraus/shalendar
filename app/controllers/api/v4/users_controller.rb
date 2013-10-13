class Api::V4::UsersController < ApiController

  version 1
  caches :index, :show, :caches_for => 5.minutes

  def index
    render json: User.paginate(:page => params[:page])
  end

  def show
    expose User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    expose User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
  end
end