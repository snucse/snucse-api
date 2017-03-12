if user.nil?
  json.id 0
  json.username "unknown"
  json.name ""
  json.profile_image_uri nil
  json.is_birthday false
else
  json.(user, :id, :username, :name, :profile_image_uri, :is_birthday)
end
