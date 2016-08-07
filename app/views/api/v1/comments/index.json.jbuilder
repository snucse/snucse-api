json.comments @comments do |comment|
  json.(comment, :id, :content)
  json.created_at do
    json.date comment.created_at.strftime("%Y%m%d")
    json.time comment.created_at.strftime("%H:%M:%S")
    json.updated comment.created_at != comment.updated_at
  end
  json.writer do
    json.(comment.writer, :id, :username, :name, :profile_image_uri)
  end
end
