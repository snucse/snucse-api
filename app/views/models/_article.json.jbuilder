json.(article, :id, :title, :content, :comment_count, :recommendation_count)
json.anonymous article.anonymous?
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
  if article.anonymous?
    json.name article.anonymous_name
  else
    json.partial! "models/user", user: article.writer
  end
end
json.tags article.article_tags, partial: "models/article_tag", as: :article_tag
