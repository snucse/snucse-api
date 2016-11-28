json.tag tag_relation.related_tag.name
json.writer do
  json.partial! "models/user", user: tag_relation.writer
end
