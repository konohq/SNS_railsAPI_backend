class Post < ApplicationRecord
  belongs_to :user

  belongs_to :repost, class_name: "Post", optional: true
  has_many :reposts, class_name: "Post", foreign_key: "repost_id", dependent: :destroy
  validates :repost_id, uniqueness: { scope: :user_id, message: "は既にリポスト済みです" }, if: :repost_id?


  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :content, presence: true, unless: :repost_id?
  validates :content, length: { maximum: 140 }
end
