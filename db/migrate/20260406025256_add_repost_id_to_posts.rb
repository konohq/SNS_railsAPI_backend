class AddRepostIdToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :repost_id, :integer
    add_index :posts, :repost_id
  end
end
