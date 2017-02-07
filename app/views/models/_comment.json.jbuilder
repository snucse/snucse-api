if comment.nil?
  json.null!
else
  json.(comment, :id, :article_id, :content, :recommendation_count, :created_at)
  json.anonymous comment.anonymous?
  if comment.parent_comment_id
    json.(comment, :parent_comment_id)
  end
  json.writer do
    if comment.anonymous?
      json.name comment.anonymous_name
    else
      json.partial! "models/user", user: comment.writer
    end
  end
end
