json.comments do
  json.count @comments.total
  json.data @comments do |comment|
    json.partial! "models/comment", comment: comment
    json.article do
      json.partial! "models/article", article: comment.article
    end
  end
end
