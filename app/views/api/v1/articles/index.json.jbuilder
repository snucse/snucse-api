json.articles @articles do |article|
  json.(article, :id, :title, :content, :created_at, :updated_at)
  json.group do
    json.(article.group, :id, :name)
  end
  json.writer do
    json.(article.writer, :id, :username, :name, :profile_image_uri)
  end
end
