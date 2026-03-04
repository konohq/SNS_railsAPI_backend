class Api::CommentsController < ApplicationController
  def index
  end

  def create
        comment = current_user.comments.build(comment_params)
    if comment.save
      render json: PostSerializer.serialize_single(comments, current_user), status: :created
    else
      render json: { errors: comments.errors.full_messages }, status: :unprocessable_entity
    end
  end



  def destroy
        comment = current_user.comments.find(params[:id])
    comment.destroy
    head :no_content
  end
end
