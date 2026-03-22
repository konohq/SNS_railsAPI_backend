class AddPostIdToPosts < ActiveRecord::Migration[8.0]
  def change
    add_reference :posts, :post, null: true, foreign_key: true
  end
end
