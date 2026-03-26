require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { User.create(username: "テスト太郎", account_id: "test_taro") }

  it "本文があれば有効であること" do
    post = Post.new(content: "こんにちは！", user: user)
    expect(post).to be_valid
  end

  it "本文が空なら無効であること" do
    post = Post.new(content: "", user: user)
    expect(post).not_to be_valid
  end

  it "本文が141文字以上なら無効であること" do
    post = Post.new(content: "a" * 141, user: user)
    expect(post).not_to be_valid
  end
end
