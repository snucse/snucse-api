json.articles @articles do |article|
  json.type "article"
  json.partial! "models/article", article: article
  json.feed_content sanitize(article.rendered_content)
  json.last_comment do
    json.partial! "models/comment", comment: article.last_comment
    if article.last_comment and article.last_comment.last_reply
      json.last_reply do
        json.partial! "models/comment", comment: article.last_comment.last_reply
      end
      json.reply_count article.last_comment.reply_count
    end
  end
end
