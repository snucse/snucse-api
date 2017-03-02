json.feeds @feeds do |feed|
  json.type "article"
  json.partial! "models/article", article: feed
  json.last_comment do
    json.partial! "models/comment", comment: feed.last_comment
    if feed.last_comment and feed.last_comment.last_reply
      json.last_reply do
        json.partial! "models/comment", comment: feed.last_comment.last_reply
      end
      json.reply_count feed.last_comment.reply_count
    end
  end
end
