class Post < ApplicationRecord
belongs_to :user
validates :content, presence: true, length: { maximum: 140 }
has_many :comments
has_many :likes

end
