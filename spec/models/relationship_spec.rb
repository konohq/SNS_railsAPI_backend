require "rails_helper"

RSpec.describe Relationship, type: :model do
  let(:follower) { FactoryBot.create(:user) }
  let(:followed) { FactoryBot.create(:user) }

  it "異なるユーザー同士であれば有効である" do
    relationship = described_class.new(follower: follower, followed: followed)

    expect(relationship).to be_valid
  end

  it "自分自身をフォローする関係は無効である" do
    relationship = described_class.new(follower: follower, followed: follower)

    expect(relationship).not_to be_valid
    expect(relationship.errors[:followed]).to be_present
  end

  it "同じ組み合わせのフォロー関係は重複できない" do
    described_class.create!(follower: follower, followed: followed)
    duplicate_relationship = described_class.new(follower: follower, followed: followed)

    expect(duplicate_relationship).not_to be_valid
    expect(duplicate_relationship.errors[:follower_id]).to be_present
  end
end
