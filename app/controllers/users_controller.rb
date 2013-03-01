class UsersController < ApplicationController
  def show
    @user = User.includes(:events, :relationships, { :rsvps => :plan }).find_by_slug(params[:id])
    @user_friends = @user.friends
    @user_inmates = @user.inmates
    @star_count = @user.friended_bys.count
    if user_signed_in?
      @is_friends = (@user.friends + @user.inmates).include?(current_user)
      if @user == current_user || current_user.is_friends_with?(@user)
        @my_ins = @user.plans.includes({ :rsvps => :guest }).where('starts_at IS NULL OR (one_time = ? AND ends_at > ?)', true, Time.zone.now)
      else 
        @my_ins = @user.plans.includes({ :rsvps => :guest }).where('friends_only = ? AND starts_at IS NULL OR (one_time = ? AND ends_at > ?)', false, true, Time.zone.now)
      end
      
      @my_ins = @my_ins.sort_by do |i|
          i.guests.joins(:reverse_relationships).where('status = ? AND follower_id = ?', 2, current_user.id).count*100 + 
            i.guests.joins(:reverse_relationships).where('status = ? AND follower_id = ?', 1, current_user.id).count
      end


      @times = @user.plans.includes({ :rsvps => :guest }).where("starts_at > ?", Time.zone.now).order('starts_at ASC')              
      @past_times = @user.plans.includes({ :rsvps => :guest }).where("starts_at < ?", Time.zone.now).order('starts_at ASC').limit(20).reverse
    else
      @my_ins = @user.plans.includes({ :rsvps => :guest }).where('friends_only = ? AND starts_at IS NULL OR (one_time = ? AND ends_at > ?)', false, true, Time.zone.now)
    end
  end

  def city_names
    @city_names = City.order(:name).where("lower(name) like ?", "%#{params[:term].downcase}%")
    render json: @city_names.map(&:name)
  end
end