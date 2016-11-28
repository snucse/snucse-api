json.tag tag.name
json.creator do
  json.partial! "models/user", user: tag.creator
end
