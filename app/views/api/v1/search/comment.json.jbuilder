json.comments do
  json.count @comments.total
  json.data @comments, partial: "models/comment", as: :comment
end
