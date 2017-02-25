json.comments do
  json.count @comments_total
  json.data @comments do |comment|
    json.partial! "models/comment", comment: comment
    json.article do
      json.(comment.article, :id, :title)
    end
  end
end
