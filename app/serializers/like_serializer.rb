class LikeSerializer
    def self.serialize(likes, current_user = nil)
    likes_array = Array.wrap(likes)

    result = likes_array.map do |like|
      {
        id: like.id,
        createdAt: like.created_at,
        user: serialize_user(like.user)
      }
    end

    likes.respond_to?(:map) ? result : result.first
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

  def self.serialize_likes(likes)
    likes.map do |like|
      {
        id: like.id,
        content: like.content,
        user: serialize_user(like.user)
      }
    end
  end
end
