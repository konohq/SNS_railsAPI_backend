require 'rails_helper'

RSpec.describe Comment, type: :model do

  let(:user) do
    User.create!(
      username: "コメント太郎",
      account_id: "comment_kun",
      email: "comment@example.com",
      password: "password123"
    )
  end

  let(:post) do
    Post.create!(
      content: "今日のランチはカレーです",
      user: user
    )
  end



  it "内容、ユーザー、投稿があれば有効であること" do
    comment = Comment.new(content: "美味しそうですね！", user: user, post: post)
    expect(comment).to be_valid
  end

  it "内容が空なら無効であること" do
    comment = Comment.new(content: "", user: user, post: post)
    expect(comment).not_to be_valid
  end

  it "内容が101文字以上なら無効であること" do
    comment = Comment.new(content: "a" * 101, user: user, post: post)
    expect(comment).not_to be_valid
  end
end