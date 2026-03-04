class CommentSerializer
  def self.serialize(comments, current_user = nil)

    comments_array = Array.wrap(comments)


    result = comments_array.map do |c|
      {
        id: c.id,
        content: c.content,
        createdAt: c.created_at,
        user: serialize_user(c.user), 
        likesCount: c.likes.size,
        isLikedByMe: !!current_user && c.likes.any? { |l| l.user_id == current_user.id },
        comments: serialize_comments(c.comments) 
      }
    end

    comments.respond_to?(:map) ? result : result.first
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