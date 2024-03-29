class CommentsController < ApplicationController
  before_filter :authenticate_user!

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/1/edit
  # def edit
  #   @comment = Comment.find(params[:id])
  # end

  # POST /comments
  # POST /comments.json
  def create
    @event = Event.find(params[:event_id])
    @comment = @event.comments.build(params[:comment])
    @comment.user_id = current_user.id
    
    respond_to do |format|
      if @comment.save
        if current_user == @event.user
          @comment_recipients = @event.guests.select { |g| g.email_comments == true && 
                                                           g != current_user && 
                                                           !g.rsvps.find_by_event_id(@event.id).muted? }
        else
          @comment_recipients = @event.guests.select { |g| (g == @event.user || 
                                                           (g.is_friends_with?(current_user)) && 
                                                           g.email_comments == true && 
                                                           g != current_user && 
                                                           !g.rsvps.find_by_event_id(@event.id).muted?) }
        end
        @comment_recipients.each do |g|
          g.delay.contact_comment(@comment)
        end

        format.html { redirect_to @event, notice: 'Chat sent' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { redirect_to @event, notice: 'Chat could not be sent. Please try again' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment = Comment.find(params[:id])
    @event = Event.find(params[:event_id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to @event }
      format.json { head :no_content }
    end
  end
end
