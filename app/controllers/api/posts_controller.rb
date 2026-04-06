class Api::PostsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    posts = Post.includes(:user, :likes, :repost, comments: :user)
                .order(created_at: :desc)
                .page(params[:page]).per(10)

    render json: PostSerializer.serialize(posts, current_user)
  end

  def create
    post = current_user.posts.build(post_params)

    if post.repost_id.present?
      target_post = Post.find_by(id: post.repost_id)

      if target_post&.repost_id.present?
        post.repost_id = target_post.repost_id
      end
    end

    if post.save
      render json: PostSerializer.serialize(post, current_user), status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    post = current_user.posts.find(params[:id])
    post.destroy
    head :no_content
  end

  private

  def post_params
    params.require(:post).permit(:content, :repost_id)
  end
end
