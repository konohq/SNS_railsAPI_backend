class Api::CommentsController < ApplicationController
   before_action :authenticate_user!, only: [ :create, :destroy ]

  def index
       post = Post.find(params[:post_id])
       comments = post.comments.includes(:user, :likes, comments: :user)

    render json: CommentSerializer.serialize(comments, current_user)
  end

  def create
    post = Post.find(params[:post_id])
    comment = current_user.comments.build(comment_params.merge(post_id: post.id))
    if comment.save
      render json: CommentSerializer.serialize(comment, current_user), status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end



  def destroy
    comment = current_user.comments.find(params[:id])
    comment.destroy
    head :no_content
  end
  private
    def comment_params
    params.require(:comment).permit(:content)
  end
end
