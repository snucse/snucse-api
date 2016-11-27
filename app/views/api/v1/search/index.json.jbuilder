json.articles do
  json.count @articles.total
  json.data @articles do |article|
    json.(article, :id, :title, :content, :recommendation_count)
    json.created_at do
      json.date article.created_at.strftime("%Y%m%d")
      json.time article.created_at.strftime("%H:%M:%S")
      json.updated article.created_at != article.updated_at
    end
    json.profiles article.profiles do |profile|
      json.(profile, :name)
      json.id profile.sid
    end
    json.writer do
      json.(article.writer, :id, :username, :name, :profile_image_uri)
    end
    json.tags article.article_tags do |tag|
      json.tag tag.tag.name
      json.writer do
        json.(tag.writer, :id, :username, :name, :profile_image_uri)
      end
    end
  end
end
json.comments do
  json.count @comments.total
  json.data @comments do |comment|
    json.(comment, :id, :content, :article_id, :recommendation_count)
    json.anonymous comment.anonymous?
    json.created_at do
      json.date comment.created_at.strftime("%Y%m%d")
      json.time comment.created_at.strftime("%H:%M:%S")
      json.updated comment.created_at != comment.updated_at
    end
    json.writer do
      if comment.anonymous?
        json.name comment.anonymous_name
      else
        json.(comment.writer, :id, :username, :name, :profile_image_uri)
      end
    end
  end
end
json.profiles do
  json.count @profiles.total
  json.data @profiles do |profile|
    json.(profile, :name, :description)
    json.id profile.sid
    json.admin do
      json.(profile.admin, :id, :username, :name)
    end
    json.tags profile.profile_tags do |tag|
      json.tag tag.tag.name
      json.writer do
        json.(tag.writer, :id, :username, :name, :profile_image_uri)
      end
    end
  end
end
json.tags do
  json.count @tags.total
  json.data @tags do |tag|
    json.tag tag.name
    json.writer do
      json.(tag.creator, :id, :username, :name, :profile_image_uri)
    end
  end
end
