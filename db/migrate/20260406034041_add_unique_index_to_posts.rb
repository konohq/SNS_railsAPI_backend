class AddUniqueIndexToPosts < ActiveRecord::Migration[8.0]
  def change
    add_index :posts, [ :user_id, :repost_id ], unique: true, where: "repost_id IS NOT NULL"
  end
end
