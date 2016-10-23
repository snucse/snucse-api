json.(@profile, :name, :description)
json.id @profile.sid
json.admin do
  json.(@profile.admin, :id, :username, :name)
end
json.tags @profile.profile_tags do |tag|
  json.tag tag.tag.name
  json.writer do
    json.(tag.writer, :id, :username, :name, :profile_image_uri)
  end
end
json.following @following
