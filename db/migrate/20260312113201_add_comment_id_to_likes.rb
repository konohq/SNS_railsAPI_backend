class AddCommentIdToLikes < ActiveRecord::Migration[8.0]
  def change
    add_column :likes, :comment_id, :integer
  end
end
