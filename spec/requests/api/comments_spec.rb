require "rails_helper"

RSpec.describe "Api::Comments", type: :request do
  let!(:current_user) { FactoryBot.create(:user) }
  let!(:other_user) { FactoryBot.create(:user) }
  let!(:post_record) { FactoryBot.create(:post, user: other_user) }

  describe "GET /api/posts/:post_id/comments" do
    it "コメント一覧を取得できる" do
      comment = FactoryBot.create(:comment, post: post_record, user: other_user, content: "一覧コメント")

      get api_post_comments_path(post_record), as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.pluck("id")).to include(comment.id)
    end
  end

  describe "POST /api/posts/:post_id/comments" do
    it "未認証ではコメントできない" do
      expect {
        post api_post_comments_path(post_record),
             params: { comment: { content: "未認証コメント" } },
             as: :json
      }.not_to change(Comment, :count)

      expect_unauthorized_json
    end

    it "未認証時は存在しない投稿へのコメントでも401が優先される" do
      expect {
        post api_post_comments_path(0),
             params: { comment: { content: "未認証コメント" } },
             as: :json
      }.not_to change(Comment, :count)

      expect_unauthorized_json
    end

    it "コメントを作成できる" do
      expect {
        post api_post_comments_path(post_record),
             params: { comment: { content: "作成コメント" } },
             headers: auth_headers_for(current_user),
             as: :json
      }.to change(current_user.comments, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["content"]).to eq("作成コメント")
    end

    it "存在しない投稿へのコメントは失敗する" do
      expect {
        post api_post_comments_path(0),
             params: { comment: { content: "存在しない投稿へのコメント" } },
             headers: auth_headers_for(current_user),
             as: :json
      }.not_to change(Comment, :count)

      expect_not_found_json
    end
  end

  describe "DELETE /api/comments/:id" do
    it "自分のコメントを削除できる" do
      comment = FactoryBot.create(:comment, post: post_record, user: current_user)

      expect {
        delete api_comment_path(comment), headers: auth_headers_for(current_user), as: :json
      }.to change(Comment, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "他人のコメントは削除できない" do
      comment = FactoryBot.create(:comment, post: post_record, user: other_user)

      expect {
        delete api_comment_path(comment), headers: auth_headers_for(current_user), as: :json
      }.not_to change(Comment, :count)

      expect_not_found_json
    end
  end
end
