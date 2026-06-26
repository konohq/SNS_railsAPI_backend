class Api::ProfilesController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(profile_params)
      render json: {
        id: current_user.id,
        username: current_user.username,
        account_id: current_user.account_id,
        bio: current_user.bio,
        avatar_url: current_user.avatar.attached? ? url_for(current_user.avatar) : nil
      }, status: :ok
    else
      render_validation_error(current_user.errors)
    end
  end

  private

  def profile_params
    params.require(:user).permit(:username, :account_id, :avatar, :bio)
  end
end
