json.feeds @feeds do |feed|
  json.type "article"
  json.partial! "models/article", article: feed
  json.last_comment do
    json.partial! "models/comment", comment: feed.last_comment
  end
end
