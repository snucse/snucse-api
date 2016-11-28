json.tag profile_tag.tag.name
json.writer do
  json.partial! "models/user", user: profile_tag.writer
end
