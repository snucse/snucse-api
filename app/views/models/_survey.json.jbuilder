json.(survey, :id, :article_id, :title, :start_time, :end_time, :show_result_type)
json.creator do
  json.partial! "models/user", user: survey.creator
end
json.anonymous survey.anonymous?
json.voted survey.voted(@user.id)
json.content survey.content_with_result(@user.id)
