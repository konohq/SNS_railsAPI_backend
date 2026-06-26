class Api::RelationshipsController < ApplicationController
  rescue_from ActiveRecord::RecordNotUnique, with: :render_duplicate_relationship

  before_action :authenticate_api_user!

  def create
    user = User.find_by(id: params[:followed_id])
    return render_not_found("フォロー対象のユーザーが見つかりません") unless user

    relationship = current_user.active_relationships.build(followed: user)

    if relationship.save
      render json: {
        status: "success",
        is_followed_by_me: true,
        followed_id: user.id
      }
    else
      render_validation_error(relationship.errors)
    end
  end

  def destroy
    user = User.find_by(id: params[:followed_id])
    return render_not_found("フォロー対象のユーザーが見つかりません") unless user

    relationship = current_user.active_relationships.find_by(followed: user)
    return render_not_found("フォロー関係が見つかりません") unless relationship

    relationship.destroy!
    render json: {
      status: "success",
      is_followed_by_me: false,
      followed_id: user.id
    }
  end

  private

  def authenticate_api_user!
    return if current_user

    render_unauthorized
  end

  def render_duplicate_relationship
    render_error(
      code: "validation_error",
      message: "入力内容に誤りがあります",
      details: [ "既にフォローしています" ],
      status: :unprocessable_content
    )
  end
end
