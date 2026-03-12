class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  validates :content, presence: true, length: { maximum: 100 }

  has_many :likes, dependent: :destroy
  
  has_many :comments, foreign_key: :parent_id, dependent: :destroy
end
