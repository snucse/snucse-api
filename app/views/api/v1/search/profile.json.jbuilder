json.profiles do
  json.count @profiles.total
  json.data @profiles, partial: "models/profile", as: :profile
end
