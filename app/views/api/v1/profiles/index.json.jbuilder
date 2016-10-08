json.profiles @profiles do |profile|
  json.(profile, :name, :description)
  json.id profile.sid
  json.admin do
    json.(profile.admin, :id, :username, :name)
  end
end
