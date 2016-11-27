json.profiles do
  json.count @profiles.total
  json.data @profiles do |profile|
    json.(profile, :name, :description)
    json.id profile.sid
    json.admin do
      json.(profile.admin, :id, :username, :name)
    end
    json.tags profile.profile_tags do |tag|
      json.tag tag.tag.name
      json.writer do
        json.(tag.writer, :id, :username, :name, :profile_image_uri)
      end
    end
  end
end
