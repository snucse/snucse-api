json.articles do
  json.count @articles.total
  json.data @articles, partial: "models/article", as: :article
end
json.comments do
  json.count @comments.total
  json.data @comments, partial: "models/comment", as: :comment
end
json.profiles do
  json.count @profiles.total
  json.data @profiles, partial: "models/profile", as: :profile
end
json.tags do
  json.count @tags.total
  json.data @tags, partial: "models/tag", as: :tag
end
