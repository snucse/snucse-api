json.articles @articles do |article|
  json.(article, :id, :title, :content, :recommendation_count)
  json.created_at do
    json.date article.created_at.strftime("%Y%m%d")
    json.time article.created_at.strftime("%H:%M:%S")
    json.updated article.created_at != article.updated_at
  end
  json.profiles article.profiles do |profile|
    json.(profile, :name)
    json.id profile.sid
  end
  json.writer do
    json.(article.writer, :id, :username, :name, :profile_image_uri)
  end
  json.tags article.article_tags do |tag|
    json.tag tag.tag.name
    json.writer do
      json.(tag.writer, :id, :username, :name, :profile_image_uri)
    end
  end
end
