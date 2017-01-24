json.contacts @contacts do |contact|
  json.partial! "models/user", user: contact
end
