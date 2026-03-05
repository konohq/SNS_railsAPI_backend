class User < ApplicationRecord
has_many :posts, dependent: :destroy
has_many :comments, dependent: :destroy
has_many :likes, dependent: :destroy
validates :username, presence: true
validates :account_id, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_]+\z/ }

has_one_attached :avatar
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
