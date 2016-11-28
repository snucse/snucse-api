json.(profile, :name, :description)
json.id profile.sid
json.admin do
  json.(profile.admin, :id, :username, :name)
end
json.tags profile.profile_tags, partial: "models/profile_tag", as: :profile_tag
