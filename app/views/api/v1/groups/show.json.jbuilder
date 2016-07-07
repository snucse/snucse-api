json.(@group, :id, :name)
json.admin do
  json.(@group.admin, :id, :username, :name)
end
