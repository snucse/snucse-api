json.profiles @profiles do |profile|
  json.(profile, :id, :name)
  json.admin do
    json.(profile.admin, :id, :username, :name)
  end
end
