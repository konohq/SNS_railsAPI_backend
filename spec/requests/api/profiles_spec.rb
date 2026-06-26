require "rails_helper"

RSpec.describe "Api::Profiles", type: :request do
  let!(:current_user) { FactoryBot.create(:user) }
  let!(:other_user) { FactoryBot.create(:user, username: "他人ユーザー", account_id: "other_profile") }

  describe "PATCH /api/profile" do
    it "未認証では更新できない" do
      patch api_profile_path,
            params: { user: { username: "未認証更新" } },
            as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it "自分のプロフィールを更新できる" do
      patch api_profile_path,
            params: { user: { username: "更新後ユーザー", account_id: "updated_user", bio: "更新後の自己紹介" } },
            headers: auth_headers_for(current_user),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        "id" => current_user.id,
        "username" => "更新後ユーザー",
        "account_id" => "updated_user",
        "bio" => "更新後の自己紹介"
      )
    end

    it "他人のIDを送っても他人のプロフィールは更新できない" do
      patch api_profile_path,
            params: { user: { id: other_user.id, username: "悪意ある更新", account_id: "malicious" } },
            headers: auth_headers_for(current_user),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(other_user.reload.username).to eq("他人ユーザー")
      expect(current_user.reload.username).to eq("悪意ある更新")
    end

    it "バリデーションエラーを返す" do
      patch api_profile_path,
            params: { user: { account_id: "" } },
            headers: auth_headers_for(current_user),
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end
  end
end
