json.partial! "models/profile", profile: @profile
json.following @following
json.last_comment do
  json.partial! "models/profile_comment", profile_comment: @profile.last_comment
end
