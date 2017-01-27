json.(article, :id, :title, :content, :rendered_content, :comment_count, :recommendation_count, :created_at)
json.rendering_mode article.rendering_mode_label
json.anonymous article.anonymous?
json.profiles article.profiles do |profile|
  json.(profile, :name)
  json.id profile.sid
end
json.writer do
  if article.anonymous?
    json.name article.anonymous_name
  else
    json.partial! "models/user", user: article.writer
  end
end
json.files article.attachments, partial: "models/attachment", as: :attachment
json.tags article.article_tags, partial: "models/article_tag", as: :article_tag
if article.survey
  json.survey_id article.survey.id
end
