conf = Rails.application.config_for(:elasticsearch)
Elasticsearch::Model.client = Elasticsearch::Client.new host: conf["host"]
