require "rails_helper"

RSpec.describe "Api::Posts", type: :request do
  let!(:current_user) { FactoryBot.create(:user) }
  let!(:other_user) { FactoryBot.create(:user) }

  describe "GET /api/posts" do
    it "投稿一覧を取得できる" do
      post_record = FactoryBot.create(:post, user: other_user, content: "一覧に表示される投稿")

      get api_posts_path, headers: auth_headers_for(current_user), as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck("id")).to include(post_record.id)
    end
  end

  describe "GET /api/posts/:id" do
    it "投稿詳細を取得できる" do
      post_record = FactoryBot.create(:post, user: other_user, content: "詳細表示の投稿")

      get api_post_path(post_record), headers: auth_headers_for(current_user), as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        "id" => post_record.id,
        "content" => "詳細表示の投稿"
      )
    end
  end

  describe "POST /api/posts" do
    it "未認証では投稿作成できない" do
      expect {
        post api_posts_path,
             params: { post: { content: "未認証投稿" } },
             as: :json
      }.not_to change(Post, :count)

      expect(response).to have_http_status(:unauthorized)
    end

    it "認証済みユーザーは投稿作成できる" do
      expect {
        post api_posts_path,
             params: { post: { content: "認証済み投稿" } },
             headers: auth_headers_for(current_user),
             as: :json
      }.to change(current_user.posts, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["content"]).to eq("認証済み投稿")
    end

    it "バリデーションエラーを返す" do
      expect {
        post api_posts_path,
             params: { post: { content: "" } },
             headers: auth_headers_for(current_user),
             as: :json
      }.not_to change(Post, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "DELETE /api/posts/:id" do
    it "自分の投稿を削除できる" do
      post_record = FactoryBot.create(:post, user: current_user)

      expect {
        delete api_post_path(post_record), headers: auth_headers_for(current_user), as: :json
      }.to change(Post, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "他人の投稿は削除できない" do
      post_record = FactoryBot.create(:post, user: other_user)

      expect {
        delete api_post_path(post_record), headers: auth_headers_for(current_user), as: :json
      }.not_to change(Post, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
