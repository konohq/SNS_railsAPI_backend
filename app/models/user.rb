class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  ALLOWED_AVATAR_CONTENT_TYPES = %w[
    image/png
    image/jpeg
    image/webp
  ].freeze
  MAX_AVATAR_SIZE = 5.megabytes

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_one_attached :avatar

  # フォロー機能
  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :followers, through: :passive_relationships, source: :follower


  validates :username, presence: true
  validates :jti, presence: true, uniqueness: true
  validates :account_id, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9_]+\z/ }, length: { maximum: 15 }
  validate :avatar_content_type
  validate :avatar_size

  # コールバック
  before_validation :generate_jti, on: :create


  def follow(other_user)
    following << other_user unless self == other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  def following_count
   self.active_relationships.count
  end

  def followers_count
   self.passive_relationships.count
  end

  def avatar_url
    avatar.attached? ? Rails.application.routes.url_helpers.rails_blob_path(avatar, only_path: true) : nil
  end

  private

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end

  def avatar_content_type
    return unless avatar.attached?
    return if avatar.blob.content_type.in?(ALLOWED_AVATAR_CONTENT_TYPES)

    errors.add(:avatar, "はPNG、JPEG、WebP形式でアップロードしてください")
  end

  def avatar_size
    return unless avatar.attached?
    return if avatar.blob.byte_size <= MAX_AVATAR_SIZE

    errors.add(:avatar, "は5MB以下にしてください")
  end
end
