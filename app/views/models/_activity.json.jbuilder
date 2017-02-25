json.(activity, :id, :action, :created_at)
json.type activity.target_type
if activity.profile
  json.profile do
    json.(activity.profile, :name)
    json.id activity.profile.sid
  end
end
if activity.article
  json.article do
    json.(activity.article, :id, :title)
  end
end
json.actor do
  json.partial! "models/user", user: activity.actor
end
