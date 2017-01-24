json.contact do
  json.partial! "models/user", user: @contact
end
json.messages @messages do |message|
  json.hello "world"
  json.partial! "models/message", message: message
end
