if profile_comment.nil?
  json.null!
else
  json.(profile_comment, :id, :profile_id, :content, :recommendation_count)
  json.created_at do
    json.date profile_comment.created_at.strftime("%Y%m%d")
    json.time profile_comment.created_at.strftime("%H:%M:%S")
    json.updated profile_comment.created_at != profile_comment.updated_at
  end
  json.writer do
    json.partial! "models/user", user: profile_comment.writer
  end
end