if profile_comment.nil?
  json.null!
else
  json.(profile_comment, :id, :content, :recommendation_count, :created_at)
  if profile_comment.parent_comment_id
    json.(profile_comment, :parent_comment_id)
  end
  json.profile_id profile_comment.profile.sid
  json.writer do
    json.partial! "models/user", user: profile_comment.writer
  end
end
