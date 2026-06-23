class AddConstraintsToRelationships < ActiveRecord::Migration[8.0]
  def up
    remove_invalid_relationships

    change_column :relationships, :follower_id, :bigint
    change_column :relationships, :followed_id, :bigint
    change_column_null :relationships, :follower_id, false
    change_column_null :relationships, :followed_id, false

    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [ :follower_id, :followed_id ], unique: true

    add_foreign_key :relationships, :users, column: :follower_id, on_delete: :cascade
    add_foreign_key :relationships, :users, column: :followed_id, on_delete: :cascade
    add_check_constraint :relationships,
                         "follower_id <> followed_id",
                         name: "relationships_cannot_follow_self"
  end

  def down
    remove_check_constraint :relationships, name: "relationships_cannot_follow_self"
    remove_foreign_key :relationships, column: :followed_id
    remove_foreign_key :relationships, column: :follower_id

    remove_index :relationships, column: [ :follower_id, :followed_id ]
    remove_index :relationships, :followed_id
    remove_index :relationships, :follower_id

    change_column_null :relationships, :followed_id, true
    change_column_null :relationships, :follower_id, true
    change_column :relationships, :followed_id, :integer
    change_column :relationships, :follower_id, :integer
  end

  private

  def remove_invalid_relationships
    execute <<~SQL.squish
      DELETE FROM relationships
      WHERE follower_id IS NULL
         OR followed_id IS NULL
         OR follower_id = followed_id
         OR follower_id NOT IN (SELECT id FROM users)
         OR followed_id NOT IN (SELECT id FROM users)
    SQL

    execute <<~SQL.squish
      DELETE FROM relationships
      WHERE id NOT IN (
        SELECT MIN(id)
        FROM relationships
        GROUP BY follower_id, followed_id
      )
    SQL
  end
end
