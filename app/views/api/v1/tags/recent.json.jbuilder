json.tags @tag_count do |tag, count|
  json.partial! "models/tag", tag: tag
  json.count count
end
