require "rails_helper"

RSpec.describe "Api::Relationships", type: :request do
  let!(:current_user) do
    User.create!(
      username: "ログインユーザー",
      account_id: "current_user",
      email: "current@example.com",
      password: "password123"
    )
  end

  let!(:target_user) do
    User.create!(
      username: "フォロー対象",
      account_id: "target_user",
      email: "target@example.com",
      password: "password123"
    )
  end

  def auth_headers_for(user)
    post user_session_path,
         params: { user: { email: user.email, password: "password123" } },
         as: :json

    token = response.parsed_body["token"] || response.headers["Authorization"]
    authorization = token.start_with?("Bearer ") ? token : "Bearer #{token}"

    { "Authorization" => authorization }
  end

  describe "POST /api/relationships" do
    it "ログイン済みユーザーが他のユーザーをフォローできる" do
      expect {
        post api_relationships_path,
             params: { followed_id: target_user.id },
             headers: auth_headers_for(current_user),
             as: :json
      }.to change(Relationship, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        "status" => "success",
        "is_followed_by_me" => true,
        "followed_id" => target_user.id
      )
      expect(current_user.reload).to be_following(target_user)
    end

    it "未ログインユーザーはフォローできない" do
      expect {
        post api_relationships_path,
             params: { followed_id: target_user.id },
             as: :json
      }.not_to change(Relationship, :count)

      expect(response).to have_http_status(:unauthorized)
    end

    it "自分自身をフォローできない" do
      expect {
        post api_relationships_path,
             params: { followed_id: current_user.id },
             headers: auth_headers_for(current_user),
             as: :json
      }.not_to change(Relationship, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "同じユーザーを二重フォローできない" do
      Relationship.create!(follower: current_user, followed: target_user)

      expect {
        post api_relationships_path,
             params: { followed_id: target_user.id },
             headers: auth_headers_for(current_user),
             as: :json
      }.not_to change(Relationship, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "存在しないユーザーIDを指定すると404を返す" do
      post api_relationships_path,
           params: { followed_id: 0 },
           headers: auth_headers_for(current_user),
           as: :json

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "DELETE /api/relationships/:followed_id" do
    it "ログイン済みユーザーがフォロー解除できる" do
      Relationship.create!(follower: current_user, followed: target_user)

      expect {
        delete api_relationship_path(target_user),
               headers: auth_headers_for(current_user),
               as: :json
      }.to change(Relationship, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        "status" => "success",
        "is_followed_by_me" => false,
        "followed_id" => target_user.id
      )
      expect(current_user.reload).not_to be_following(target_user)
    end

    it "未ログインユーザーはフォロー解除できない" do
      Relationship.create!(follower: current_user, followed: target_user)

      expect {
        delete api_relationship_path(target_user), as: :json
      }.not_to change(Relationship, :count)

      expect(response).to have_http_status(:unauthorized)
    end

    it "対象のRelationshipが存在しない場合は404を返す" do
      delete api_relationship_path(target_user),
             headers: auth_headers_for(current_user),
             as: :json

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to be_present
    end
  end
end
