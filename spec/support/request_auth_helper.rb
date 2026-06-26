module RequestAuthHelper
  def auth_headers_for(user, password: "password123")
    post user_session_path,
         params: { user: { email: user.email, password: password } },
         as: :json

    token = response.parsed_body["token"] || response.headers["Authorization"]
    authorization = token.start_with?("Bearer ") ? token : "Bearer #{token}"

    { "Authorization" => authorization }
  end
end
