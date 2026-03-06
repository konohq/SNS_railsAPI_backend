require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:user) do
   User.create!(
      username: "テスト太郎",
      account_id: "test_001",
      email: "test@example.com",
      password: "password123"
   )
  end

  let(:post) do
    Post.create!(
      content: "テスト投稿です",
      user: user
    )
  end

  it "ユーザーと投稿があれば有効であること" do
    like = Like.new(user: user, post: post)
    expect(like).to be_valid
  end

  it "同じ投稿に二回いいねはできないこと" do

    Like.create!(user: user, post: post)

    duplicate_like = Like.new(user: user, post: post)
    expect(duplicate_like).not_to be_valid
  end
end