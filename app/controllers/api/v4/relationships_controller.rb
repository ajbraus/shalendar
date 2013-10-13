class Api::V4::RelationshipsController < ApiController
  
  version 1
  before_filter :authenticate_user!

  def create
    # [:relationship][:followed_id, :friend, :ignore]

    @user = User.find(params[:relationship][:followed_id])
    @intro = Relationship.where('followed_id = ? AND follower_id = ? AND status = ?', @user.id, current_user.id, 2) #REFACTOR
      if params[:relationship][:friend] == true
        current_user.friend!(@user)
      else
        current_user.inmate!(@user)
        @user.contact_new_inmate(current_user)
      end
    else
      if params[:relationship][:friend] == true      
        current_user.friend!(@user)
      else
        current_user.re_inmate!(@user)
      end
    end

    unless @relationship.updated_at > Time.zone.now - 1.hour
      @user.delay.contact_friend(current_user)
    end
  end

  def destroy
    # [:relationship][:followed_id, :friend, :ignore]

    @user = User.find_by_id(params[:followed_id])
    @intro = Relationship.where('followed_id = ? AND follower_id = ? AND status = ?', @user.id, current_user.id, 2)
    if params[:relationship][:friend] == true
      current_user.unfriend!(@user)
    elsif params[:relationship][:ignore]
      current_user.ignore!(@user)
    else
      @intro.destroy
    end

    render :json => { :unstarred_id => @user.id }
  end

  def search_for_friends
    # [:search]
    expose User.search(params[:search])
  end
  
  def search_for_fb_friends
    @graph = Koala::Facebook::API.new(params[:access_token]) 
    expose current_user.fb_friends(@graph)[0].reject{|fu|current_user.following?(fu)}
  end
end
