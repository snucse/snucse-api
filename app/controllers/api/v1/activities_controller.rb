class Api::V1::ActivitiesController < Api::V1::ApiController
  DEFAULT_LIMIT = 10
  api! "활동 목록을 전달한다."
  param :profileId, String, desc: "특정 프로필의 활동만 보고 싶은 경우 설정", required: false
  param :filterType, ["Article", "Profile", "Comment", "ProfileComment", "ArticleTag", "ProfileTag", "ImageTag", "TagRelation"], desc: "특정 종류의 활동만 보고 싶은 경우 설정", required: false
  param :filterAction, ["create", "update"], desc: "특정 동작의 활동만 보고 싶은 경우 설정", required: false
  param :page, Integer, desc: "결과 페이지의 번호, 기본값은 1", required: false
  param :limit, Integer, desc: "결과의 최대 개수, 기본값은 10", required: false
  example <<-EOS
  {
    "count": 123,
    "activities": [
      {"id": 10, "type": "Profile", "action": "create", "profile": {"id": "_17", "name": "17학번 모임"}, "actor": {...}, "createdAt": "..."}, // 프로필 생성
      {"id": 9, "type": "Article", "action": "create", "article": {"id": 123, "title": "글제목"}, "actor": {...}, "createdAt": "..."}, // 글 작성
      {"id": 8, "type": "Article", "action": "update", "article": {"id": 123, "title": "글제목"}, "actor": {...}, "createdAt": "..."}, // 글 수정
      {"id": 7, "type": "Comment", "action": "create", "article": {"id": 123, "title": "글제목"}, "actor": {...}, "createdAt": "..."}, // 댓글 작성
      {"id": 6, "type": "Comment", "action": "update", "article": {"id": 123, "title": "글제목"}, "actor": {...}, "createdAt": "..."}, // 댓글 수정
      {"id": 5, "type": "ProfileComment", "action": "create", "profile": {"id": "_17", "name": "17학번 모임"}, "actor": {...}, "createdAt": "..."}, // 프로필 댓글 작성
      {"id": 4, "type": "ProfileComment", "action": "update", "profile": {"id": "_17", "name": "17학번 모임"}, "actor": {...}, "createdAt": "..."}, // 프로필 댓글 수정
      {"id": 3, "type": "ArticleTag", "action": "create", "article": {"id": 123, "title": "글제목"}, "actor": {...}, "createdAt": "..."}, // 태그 등록
      {"id": 2, "type": "ImageTag", "action": "create", "article": {"id": 123, "title": "글제목"}, "actor": {...}, "createdAt": "..."}, // 이미지 태그 등록
      {"id": 1, "type": "ProfileTag", "action": "create", "profile": {"id": "_17", "name": "17학번 모임"}, "actor": {...}, "createdAt": "..."}, // 프로필 태그 등록
      ...
    ]
  }
  EOS
  def index
    limit = (params[:limit] || DEFAULT_LIMIT).to_i
    offset = limit * ((params[:page] || 1).to_i - 1)
    @activities = Activity.all.includes(:actor, :profile, :article)
    if params[:profileId]
      profile = Profile.find_by_sid!(params[:profileId])
      @activities = @activities.joins("LEFT OUTER JOIN articles_profiles ON activities.article_id = articles_profiles.article_id").where("activities.profile_id = ? OR articles_profiles.profile_id = ?", profile.id, profile.id)
    end
    @activities = @activities.where(target_type: params[:filterType]) if params[:filterType]
    @activities = @activities.where(action: params[:filterAction]) if params[:filterAction]
    @count = @activities.count
    @activities = @activities.limit(limit).offset(offset)
  end
end
