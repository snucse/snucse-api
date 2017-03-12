json.(image_tag, :left, :top, :width, :height)
json.tag image_tag.tag.name
json.writer do
  json.partial! "models/user", user: image_tag.writer
end
