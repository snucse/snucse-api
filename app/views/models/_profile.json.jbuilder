json.(profile, :name, :description, :comment_count)
json.id profile.sid
json.admin do
  json.(profile.admin, :id, :username, :name)
end
json.tags profile.profile_tags, partial: "models/profile_tag", as: :profile_tag
