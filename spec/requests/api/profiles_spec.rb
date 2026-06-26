require "rails_helper"

RSpec.describe "Api::Profiles", type: :request do
  let!(:current_user) { FactoryBot.create(:user) }
  let!(:other_user) { FactoryBot.create(:user, username: "他人ユーザー", account_id: "other_profile") }

  def uploaded_avatar(filename:, content_type:, size:)
    tempfile = Tempfile.new([ "avatar", File.extname(filename) ])
    tempfile.binmode
    tempfile.write("a" * size)
    tempfile.rewind
    uploaded_tempfiles << tempfile

    Rack::Test::UploadedFile.new(tempfile.path, content_type, true)
  end

  def uploaded_tempfiles
    @uploaded_tempfiles ||= []
  end

  describe "PATCH /api/profile" do
    it "未認証では更新できない" do
      patch api_profile_path,
            params: { user: { username: "未認証更新" } },
            as: :json

      expect_unauthorized_json
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

    it "有効な画像形式ならavatarを更新できる" do
      patch api_profile_path,
            params: {
              user: {
                avatar: uploaded_avatar(filename: "avatar.png", content_type: "image/png", size: 1.kilobyte)
              }
            },
            headers: auth_headers_for(current_user)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["avatar_url"]).to be_present
      expect(current_user.reload.avatar).to be_attached
    end

    it "不正なcontent_typeなら422を返す" do
      patch api_profile_path,
            params: {
              user: {
                avatar: uploaded_avatar(filename: "avatar.txt", content_type: "text/plain", size: 1.kilobyte)
              }
            },
            headers: auth_headers_for(current_user)

      expect_validation_error_json
      expect(response.parsed_body.dig("error", "details", "avatar")).to be_present
    end

    it "5MBを超えるavatarは422を返す" do
      patch api_profile_path,
            params: {
              user: {
                avatar: uploaded_avatar(filename: "large.png", content_type: "image/png", size: 5.megabytes + 1)
              }
            },
            headers: auth_headers_for(current_user)

      expect_validation_error_json
      expect(response.parsed_body.dig("error", "details", "avatar")).to be_present
    end

    it "バリデーションエラーを返す" do
      patch api_profile_path,
            params: { user: { account_id: "" } },
            headers: auth_headers_for(current_user),
            as: :json

      expect_validation_error_json
      expect(response.parsed_body.dig("error", "details", "account_id")).to be_present
    end
  end
end
