json.(@profile, :name, :description)
json.id @profile.sid
json.admin do
  json.(@profile.admin, :id, :username, :name)
end
json.tags @profile.tags do |tag|
  json.tag tag.name
end
json.following @following
