json.comments @comments do |comment|
  json.partial! "models/comment", comment: comment
  if comment.last_reply
    json.last_reply do
      json.partial! "models/comment", comment: comment.last_reply
    end
  end
end
