json.tags @tag_count do |tag, count|
  json.tag tag.name
  json.count count
  json.creator do
    json.(tag.creator, :id, :username, :name, :profile_image_uri)
  end
end
