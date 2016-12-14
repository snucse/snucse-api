json.profile_comments @profile_comments do |profile_comment|
  json.partial! "models/profile_comment", profile_comment: profile_comment
  if profile_comment.last_reply
    json.last_reply do
      json.partial! "models/profile_comment", profile_comment: profile_comment.last_reply
    end
  end
end
