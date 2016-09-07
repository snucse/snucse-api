json.(@profile, :id, :sid, :name, :description)
json.admin do
  json.(@profile.admin, :id, :username, :name)
end
json.following @following
