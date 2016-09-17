json.feeds @feeds do |feed|
  json.type "article"
  json.(feed, :id, :title, :content)
  json.created_at do
    json.date feed.created_at.strftime("%Y%m%d")
    json.time feed.created_at.strftime("%H:%M:%S")
    json.updated feed.created_at != feed.updated_at
  end
  json.group do
    json.(feed.group, :id, :name)
  end
  json.writer do
    json.(feed.writer, :id, :username, :name, :profile_image_uri)
  end
  json.last_comment do
    if feed.last_comment.nil?
      json.null!
    else
      json.(feed.last_comment, :id, :content)
      json.created_at do
        json.date feed.last_comment.created_at.strftime("%Y%m%d")
        json.time feed.last_comment.created_at.strftime("%H:%M:%S")
        json.updated feed.last_comment.created_at != feed.last_comment.updated_at
      end
      json.writer do
        json.(feed.last_comment.writer, :id, :username, :name, :profile_image_uri)
      end
    end
  end
end
