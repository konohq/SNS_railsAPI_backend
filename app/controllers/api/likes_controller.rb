class Api::LikesController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :destroy ]

  def create
    post = Post.find(params[:post_id])
    like = current_user.likes.build(post: post)
    if like.save
      render json: {
        likesCount: post.likes.size,
        isLikedByMe: true
      }, status: :created
    else
      render_validation_error(like.errors)
    end
  end

  def destroy
    post = Post.find(params[:post_id])
    like = post.likes.find_by(user: current_user)

    if like&.destroy
      render json: {
        likesCount: post.likes.size,
        isLikedByMe: false
      }, status: :ok
    else
      head :no_content
    end
  end
end
