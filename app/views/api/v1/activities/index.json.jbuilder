json.count @count
json.activities @activities do |activity|
  json.partial! "models/activity", activity: activity
  if @tag_map[activity.id]
    json.tag @tag_map[activity.id]
  end
end
