json.articles @articles do |article|
  json.(article, :id, :title, :content)
  json.created_at do
    json.date article.created_at.strftime("%Y%m%d")
    json.time article.created_at.strftime("%H:%M:%S")
    json.updated article.created_at != article.updated_at
  end
  json.profile do
    json.(article.profile, :id, :name)
  end
  json.writer do
    json.(article.writer, :id, :username, :name, :profile_image_uri)
  end
end
