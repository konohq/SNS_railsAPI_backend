class Api::UsersController < ApplicationController
  before_action :authenticate_user!, only: [ :update, :destroy, :following, :followers ]

  def index
    users = User.includes(:posts).all.page(params[:page]).per(20)
    render json: UserSerializer.serialize(users, current_user)
  end

  def show
    user = User.includes(:posts).find(params[:id])
    render json: UserSerializer.serialize(user, current_user)
  end

  def following
    @user = User.find(params[:id])
    @users = @user.following

    render json: @users.map { |u| PostSerializer.serialize_user(u, current_user) }
  end

  def followers
    @user = User.find(params[:id])
    @users = @user.followers
    render json: @users.map { |u| PostSerializer.serialize_user(u, current_user) }
  end

  def update
    user = current_user
    if user.update(user_params)

      render json: PostSerializer.serialize_user(user, current_user)
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    user = current_user
    user.destroy
    head :no_content
  end

  private

  def user_params
    params.require(:user).permit(:username, :account_id, :avatar, :bio)
  end
end
