json.profiles @follows do |follow|
  json.partial! "models/profile", profile: follow.profile
  json.star follow.star
  if follow.tab
    json.tab follow.tab
  end
end
