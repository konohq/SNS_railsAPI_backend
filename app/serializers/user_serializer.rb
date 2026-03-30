class UserSerializer
  def self.serialize(users, current_user = nil)
    users_array = Array.wrap(users)

    result = users_array.map do |u|
      {
        id: u.id,
        username: u.username,
        accountId: u.account_id,
        avatarUrl: u.avatar_url,
        bio: u.bio,
        createdAt: u.created_at,
        postsCount: u.respond_to?(:posts) ? u.posts.size : 0
      }
    end

    users.respond_to?(:each) ? result : result.first
  end
end
