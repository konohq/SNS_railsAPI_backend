class PostSerializer
  def self.serialize(posts, current_user = nil)
    posts_array = Array.wrap(posts)

    result = posts_array.map do |post|
      {
        id: post.id,
        content: post.content,
        createdAt: post.created_at,
        user: serialize_user(post.user, current_user),
        likesCount: post.likes.size,
        isLikedByMe: !!current_user && post.likes.any? { |l| l.user_id == current_user.id },
        comments: serialize_comments(post.comments),
        repost: serialize_repost(post.repost, current_user)
      }
    end

    posts.respond_to?(:map) ? result : result.first
  end

  private

  def self.serialize_repost(repost, current_user)
    return nil unless repost

    {
      id: repost.id,
      content: repost.content,
      createdAt: repost.created_at,
      user: serialize_user(repost.user, current_user)
    }
  end

  def self.serialize_user(user, current_user)
    return nil unless user
    {
      id: user.id,
      username: user.username,
      account_id: user.account_id,
      avatarUrl: user.avatar_url,
      bio: user.bio,

      following_count: user.following_count || 0,
      followers_count: user.followers_count || 0,

      is_followed_by_me: !!current_user && current_user.following?(user)
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
