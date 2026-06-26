class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  include ActionController::MimeResponds
  respond_to :json
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  protected

  def authenticate_user!
    return if user_signed_in?

    render_unauthorized
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :account_id ])

    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :account_id ])
  end

  def render_error(code:, message:, status:, details: nil)
    error = {
      code: code,
      message: message
    }
    error[:details] = details if details.present?

    render json: { error: error }, status: status
  end

  def render_bad_request
    render_error(
      code: "bad_request",
      message: "リクエスト内容が正しくありません",
      status: :bad_request
    )
  end

  def render_not_found(message = nil)
    render_error(
      code: "not_found",
      message: message.is_a?(String) ? message : "対象のデータが見つかりません",
      status: :not_found
    )
  end

  def render_unauthorized(message = "認証が必要です")
    render_error(
      code: "unauthorized",
      message: message,
      status: :unauthorized
    )
  end

  def render_forbidden(message = "この操作は許可されていません")
    render_error(
      code: "forbidden",
      message: message,
      status: :forbidden
    )
  end

  def render_validation_error(errors)
    details = errors.respond_to?(:to_hash) ? errors.to_hash(true) : Array(errors)

    render_error(
      code: "validation_error",
      message: "入力内容に誤りがあります",
      details: details,
      status: :unprocessable_content
    )
  end
end
