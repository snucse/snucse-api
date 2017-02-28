json.(profile, :name, :description, :rendered_description, :comment_count)
json.id profile.sid
json.rendering_mode profile.rendering_mode_label
json.admin do
  json.(profile.admin, :id, :username, :name)
end
json.tags profile.profile_tags, partial: "models/profile_tag", as: :profile_tag
