class Api::SessionsController < Devise::SessionsController
  respond_to :json

  def create
    self.resource = User.find_for_database_authentication(email: params.dig(:user, :email))

    unless resource&.valid_password?(params.dig(:user, :password))
      return render_unauthorized("メールアドレスまたはパスワードが正しくありません")
    end

    sign_in(resource_name, resource)

    render json: {
      token: request.env["warden-jwt_auth.token"],
      id: resource.id,
      email: resource.email,
      username: resource.username,
      account_id: resource.account_id,
      avatar_url: resource.avatar_url
    }
  end

  private


  def respond_with(resource, _opts = {})
    render json: {
      message: "ログイン成功",
      user: resource
    }, status: :ok
  end


  def respond_to_on_destroy(_resource = nil)
    render json: { message: "ログアウト成功" }, status: :ok
  end
end
