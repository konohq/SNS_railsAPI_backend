class UserSerializer
  def self.serialize(users, current_user = nil)
    users_array = Array.wrap(users)

    result = users_array.map do |u|
      {
        id: u.id,
        username: u.username,
        accountId: u.account_id,
        avatarUrl: u.avatar_url,
        createdAt: u.created_at,
        postsCount: u.posts.size,  
      }
    end

    users.respond_to?(:map) ? result : result.first
  end

  private

  def self.serialize_user(user)
    return nil unless user
    {
      id: user.id,
      username: user.username,
      avatarUrl: user.avatar_url
    }
  end
end