class Api::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private


  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        message: "サインアップ完了",
        user: resource
      }, status: :ok
    else
      render_validation_error(resource.errors)
    end
  end
end
