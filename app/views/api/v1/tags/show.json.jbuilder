json.partial! "models/tag", tag: @tag
json.articles @tag.recent_articles, partial: "models/article", as: :article
json.profiles @tag.profiles, partial: "models/profile", as: :profile
json.related_tags @tag.tag_relations, partial: "models/tag_relation", as: :tag_relation
