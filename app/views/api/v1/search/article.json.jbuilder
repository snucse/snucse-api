json.articles do
  json.count @articles.total
  json.data @articles, partial: "models/article", as: :article
end
