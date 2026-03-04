class PostSerializer
  def self.serialize(posts, current_user = nil)

    posts_array = Array.wrap(posts)


    result = posts_array.map do |post|
      {
        id: post.id,
        content: post.content,
        createdAt: post.created_at,
        user: serialize_user(post.user), 
        likesCount: post.likes.size,
        isLikedByMe: !!current_user && post.likes.any? { |l| l.user_id == current_user.id },
        comments: serialize_comments(post.comments) 
      }
    end

    posts.respond_to?(:map) ? result : result.first
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

  def self.serialize_comments(comments)
    comments.map do |c|
      {
        id: c.id,
        content: c.content,
        user: { id: c.user.id, username: c.user.username }
      }
    end
  end
end