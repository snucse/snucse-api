if comment.nil?
  json.null!
else
  json.(comment, :id, :article_id, :content, :recommendation_count)
  json.anonymous comment.anonymous?
  json.created_at do
    json.date comment.created_at.strftime("%Y%m%d")
    json.time comment.created_at.strftime("%H:%M:%S")
    json.updated comment.created_at != comment.updated_at
  end
  json.writer do
    if comment.anonymous?
      json.name comment.anonymous_name
    else
      json.partial! "models/user", user: comment.writer
    end
  end
end
