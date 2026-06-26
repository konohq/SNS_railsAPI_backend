require "rails_helper"

RSpec.describe "Api::Likes", type: :request do
  let!(:current_user) { FactoryBot.create(:user) }
  let!(:post_record) { FactoryBot.create(:post) }

  describe "POST /api/posts/:post_id/like" do
    it "未認証ではいいねできない" do
      expect {
        post api_post_like_path(post_record), as: :json
      }.not_to change(Like, :count)

      expect_unauthorized_json
    end

    it "未認証時は存在しない投稿へのいいねでも401が優先される" do
      expect {
        post api_post_like_path(0), as: :json
      }.not_to change(Like, :count)

      expect_unauthorized_json
    end

    it "いいねできる" do
      expect {
        post api_post_like_path(post_record), headers: auth_headers_for(current_user), as: :json
      }.to change(current_user.likes, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include(
        "likesCount" => 1,
        "isLikedByMe" => true
      )
    end

    it "二重いいねはできない" do
      FactoryBot.create(:like, user: current_user, post: post_record)

      expect {
        post api_post_like_path(post_record), headers: auth_headers_for(current_user), as: :json
      }.not_to change(Like, :count)

      expect_validation_error_json
      expect(response.parsed_body.dig("error", "details", "user_id")).to be_present
    end

    it "存在しない投稿にはいいねできない" do
      expect {
        post api_post_like_path(0), headers: auth_headers_for(current_user), as: :json
      }.not_to change(Like, :count)

      expect_not_found_json
    end
  end

  describe "DELETE /api/posts/:post_id/like" do
    it "いいね解除できる" do
      FactoryBot.create(:like, user: current_user, post: post_record)

      expect {
        delete api_post_like_path(post_record), headers: auth_headers_for(current_user), as: :json
      }.to change(Like, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        "likesCount" => 0,
        "isLikedByMe" => false
      )
    end
  end
end
