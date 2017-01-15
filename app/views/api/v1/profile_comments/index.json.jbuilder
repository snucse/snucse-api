json.profile_comments @profile_comments do |profile_comment|
  json.partial! "models/profile_comment", profile_comment: profile_comment
  if profile_comment.last_reply
    json.last_reply do
      json.partial! "models/profile_comment", profile_comment: profile_comment.last_reply
    end
    json.reply_count profile_comment.reply_count
  end
end
