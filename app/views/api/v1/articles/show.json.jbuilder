json.partial! "models/article", article: @article
json.last_comment do
  json.partial! "models/comment", comment: @article.last_comment
  if @article.last_comment and @article.last_comment.last_reply
    json.last_reply do
      json.partial! "models/comment", comment: @article.last_comment.last_reply
    end
    json.reply_count @article.last_comment.reply_count
  end
end
