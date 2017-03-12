json.id attachment.id
json.name attachment.file_identifier
json.path attachment.path
json.tags attachment.image_tags, partial: "models/image_tag", as: :image_tag
