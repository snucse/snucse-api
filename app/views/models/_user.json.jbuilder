if user.nil?
  json.id 0
  json.username "unknown"
  json.name ""
  json.profile_image_uri nil
else
  json.(user, :id, :username, :name, :profile_image_uri)
end
