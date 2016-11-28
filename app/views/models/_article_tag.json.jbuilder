json.tag article_tag.tag.name
json.writer do
  json.partial! "models/user", user: article_tag.writer
end
