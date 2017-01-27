class Api::V1::FeedsController < Api::V1::ApiController
  skip_before_action :check_user_level
  DEFAULT_LIMIT = 10
  api! "피드 목록을 전달한다."
  param :sinceId, Integer, desc: "설정된 경우 ID가 이 값보다 큰 결과만 보낸다.", required: false
  param :maxId, Integer, desc: "설정된 경우 ID가 이 값 이하인 결과만 보낸다.", required: false
  param :limit, Integer, desc: "결과의 최대 개수, 기본값은 10이다.", required: false
  example <<-EOS
  {
    "feeds": [
      {"id": 1, "title": "title", ...},
      ...
    ]
  }
  EOS
  def index
    limit = params[:limit] || DEFAULT_LIMIT
    @feeds = @user.feeds.includes(:profiles, :writer, :survey, last_comment: :last_reply).order(id: :desc).limit(limit)
    @feeds = @feeds.where("articles.id > ?", params[:sinceId]) if params[:sinceId]
    @feeds = @feeds.where("articles.id <= ?", params[:maxId]) if params[:maxId]
  end
end
