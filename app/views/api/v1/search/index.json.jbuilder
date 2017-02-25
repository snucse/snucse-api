json.articles do
  json.count @articles.total
  json.data @articles, partial: "models/article", as: :article
end
json.comments do
  json.count @comments_total
  json.data @comments do |comment|
    json.partial! "models/comment", comment: comment
    json.article do
      json.partial! "models/article", article: comment.article
    end
  end
end
json.profiles do
  json.count @profiles.total
  json.data @profiles, partial: "models/profile", as: :profile
end
json.tags do
  json.count @tags.total
  json.data @tags, partial: "models/tag", as: :tag
end
