class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_one_attached :avatar

  validates :username, presence: true
  validates :jti, presence: true, uniqueness: true 
  validates :account_id, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_]+\z/ }

  before_validation :generate_jti, on: :create
  after_validation :report_validation_errors, if: -> { errors.any? }

  def report_validation_errors
    puts "--- [Validation Error Detail] ---"
    puts errors.full_messages
    puts "---------------------------------"
  end
  

  def avatar_url
  if avatar.attached?
    Rails.application.routes.url_helpers.rails_blob_path(avatar, only_path: true)
  else
    nil
  end
end

  private
  

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end
end