require 'rails_helper'

RSpec.describe User, type: :model do

  let(:valid_attributes) do
    {
      username: "テスト太郎",
      account_id: "test_001",
      email: "test@example.com",
      password: "password123"
    }
  end

  it "名前、アカウントID、メール、パスワードがあれば有効であること" do
    user = User.new(valid_attributes)
    expect(user).to be_valid
  end

  it "アカウントIDが重複していたら無効であること" do

    User.create!(valid_attributes)
    

    user2 = User.new(valid_attributes.merge(email: "jiro@example.com"))
    
    expect(user2).not_to be_valid
    expect(user2.errors[:account_id]).to include("has already been taken")
  end

  it "アカウントIDに日本語が含まれていたら無効であること" do
    user = User.new(valid_attributes.merge(account_id: "たろう"))
    expect(user).not_to be_valid
  end
end