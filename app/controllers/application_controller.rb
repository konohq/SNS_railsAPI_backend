class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  include ActionController::MimeResponds
  respond_to :json
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :account_id ])

    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :account_id ])
  end

  def render_not_found
    render json: {
      error: {
        code: "not_found",
        message: "対象のデータが見つかりません"
      }
    }, status: :not_found
  end
end
