json.articles @articles do |article|
  json.type "article"
  json.partial! "models/article", article: article
  json.last_comment do
    json.partial! "models/comment", comment: article.last_comment
  end
end
