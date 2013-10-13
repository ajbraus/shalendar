class Api::V4::CommentsController < ApiController
  
  def create
    @event = Event.find(params[:event_id])
    @event.comments.create(params[:comment])
    if @event.save

    else
      
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
  end

  # def index
  #   expose Comment.paginate(:page => params[:page])
  # end

  # def show
  #   expose Comment.find(params[:id])
  # end

  # def new
  #   @event = Event.find(params[:id])
  #   @comment = @event.comments.new
  # end

  # def edit
  #   expose Comment.find(params[:id])
  # end

  # def update
  #   @comment = Comment.find(params[:id])
  #   @comment.update_attributes(params[:comment])
  # end
end