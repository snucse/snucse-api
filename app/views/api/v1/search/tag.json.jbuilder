json.tags do
  json.count @tags.total
  json.data @tags, partial: "models/tag", as: :tag
end
