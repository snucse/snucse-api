json.profiles @profiles do |profile|
  json.(profile, :name)
  json.id profile.sid
end
