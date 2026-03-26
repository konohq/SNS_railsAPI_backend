class Api::RelationshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    user = User.find(params[:followed_id])

    if current_user.follow(user)
      render json: {
        status: "success",
        is_followed_by_me: true,
        followed_id: user.id
      }
    else
      render json: { status: "error" }, status: :unprocessable_entity
    end
  end


  def destroy
    user = User.find(params[:id])

    if current_user.unfollow(user)
      render json: {
        status: "success",
        is_followed_by_me: false,
        followed_id: user.id
      }
    else
      render json: { status: "error" }, status: :unprocessable_entity
    end
  end
end
