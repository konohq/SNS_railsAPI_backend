require "rails_helper"

RSpec.describe "Api::Authentication", type: :request do
  describe "POST /users" do
    let(:valid_params) do
      {
        user: {
          username: "新規ユーザー",
          account_id: "new_user",
          email: "new_user@example.com",
          password: "password123"
        }
      }
    end

    it "ユーザー登録に成功する" do
      expect {
        post user_registration_path, params: valid_params, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["message"]).to eq("サインアップ完了")
    end

    it "メールアドレスが重複していると登録に失敗する" do
      FactoryBot.create(:user, email: "new_user@example.com")

      expect {
        post user_registration_path, params: valid_params, as: :json
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "必須項目が不足していると登録に失敗する" do
      expect {
        post user_registration_path,
             params: { user: { email: "", password: "" } },
             as: :json
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "POST /users/sign_in" do
    let!(:user) { FactoryBot.create(:user, email: "login@example.com", password: "password123") }

    it "ログインに成功しJWTを発行する" do
      post user_session_path,
           params: { user: { email: user.email, password: "password123" } },
           as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["token"]).to be_present
      expect(response.parsed_body).to include(
        "id" => user.id,
        "email" => user.email,
        "account_id" => user.account_id
      )
    end

    it "パスワードが誤っているとログインに失敗する" do
      post user_session_path,
           params: { user: { email: user.email, password: "wrong-password" } },
           as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it "存在しないユーザーではログインに失敗する" do
      post user_session_path,
           params: { user: { email: "missing@example.com", password: "password123" } },
           as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /users/sign_out" do
    let!(:user) { FactoryBot.create(:user, email: "logout@example.com", password: "password123") }

    it "ログアウトに成功し、ログアウト後のJWTを無効化する" do
      headers = auth_headers_for(user)

      delete destroy_user_session_path, headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["message"]).to eq("ログアウト成功")

      get api_posts_path, headers: headers, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
