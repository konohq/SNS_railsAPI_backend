class Api::LikesController < ApplicationController  before_action :authenticate_user!, only: [:create, :destroy]

  def index
       post = Post.find(params[:post_id])
       likes = post.likes.includes(:user)

    render json: LikeSerializer.serialize(comments, current_user)
  end

  def create
    post = Post.find(params[:post_id])
    like = current_user.likes.build(post_id: post_id)
    if like.save
      render json: LikeSerializer.serialize(like, current_user), status: :created
    else
      render json: { errors: like.errors.full_messages }, status: :unprocessable_entity
    end
  end



  def destroy
    like = current_user.likes.find(params[:id])
    like.destroy
    head :no_content
  end

  private
    def comment_params
    params.require(:comment).permit(:content)
  end
end
