conf = Rails.application.config_for(:redis)
$redis = Redis.new(host: conf["host"], port: conf["port"], db: conf["db"])
