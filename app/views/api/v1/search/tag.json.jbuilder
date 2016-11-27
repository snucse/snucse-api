json.tags do
  json.count @tags.total
  json.data @tags do |tag|
    json.tag tag.name
    json.creator do
      json.(tag.creator, :id, :username, :name, :profile_image_uri)
    end
  end
end
