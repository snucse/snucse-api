class Api::V1::FeedsController < Api::V1::ApiController
  api! "피드 목록을 전달한다."
  example <<-EOS
  {
    "feeds": [
      {"id": 1, "title": "title", ...},
      ...
    ]
  }
  EOS
  def index
    @feeds = @user.feeds.includes(:profiles, :writer, :last_comment).order(id: :desc)
  end
end
