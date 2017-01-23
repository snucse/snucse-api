class Api::V1::ArticlesController < Api::V1::ApiController
  include AccessControl
  skip_before_action :check_user_level

  DEFAULT_LIMIT = 10
  api! "글 목록을 전달한다."
  param :profileId, String, desc: "설정된 경우 특정 프로필의 글만 전달한다.", required: false
  param :sinceId, Integer, desc: "설정된 경우 ID가 이 값보다 큰 결과만 보낸다.", required: false
  param :maxId, Integer, desc: "설정된 경우 ID가 이 값 이하인 결과만 보낸다.", required: false
  param :limit, Integer, desc: "결과의 최대 개수, 기본값은 10이다.", required: false
  example <<-EOS
  {
    "articles": [
      {"id": 1, "title": "title", ...},
      ...
    ]
  }
  EOS
  def index
    limit = params[:limit] || DEFAULT_LIMIT
    @articles = Article.all.includes(:profiles, :writer, last_comment: :last_reply).limit(limit)
    @articles = Profile.find_by_sid!(params[:profileId]).articles.includes(:profiles, :writer).limit(limit) if params[:profileId]
    @articles = @articles.where("articles.id > ?", params[:sinceId]) if params[:sinceId]
    @articles = @articles.where("articles.id <= ?", params[:maxId]) if params[:maxId]
  end

  api! "글을 조회한다."
  example <<-EOS
  {
    "id": 1,
    "title": "title",
    "content": "content",
    "createdAt": "2016-07-01T00:00:00.000Z",
    "updatedAt": "2016-07-01T00:00:00.000Z",
    "profiles": [
      {"id": 1, "name": "13학번 모임"}
    ],
    "writer": {
      "id": 1,
      "username": "writer",
      "name": "작성자",
      "profileImageUri": "http://placehold.it/100x100"
    },
    "files": [
      {"id": 1, "name": "image.jpg", "path": "/api/v1/files/1"},
      ...
    ],
    "tags": [
      {"tag": "태그", "writer": {...}},
      ...
    ]
  }
  EOS
  def show
    @article = Article.find params[:id]
    check_article(@article)
  end

  api! "글을 생성한다."
  param :profileIds, String, desc: "글이 작성되는 프로필의 ID, ','로 연결된 문자열 목록", required: true
  param :title, String, desc: "글 제목", required: true, empty: false
  param :content, String, desc: "글 내용", required: true, empty: false
  param :renderingMode, ["text", "md"], desc: "글 렌더링 모드(텍스트/markdown/html)", required: true
  param :files, Array, of: File, desc: "첨부파일의 목록", required: false
  def create
    profiles = params[:profileIds].split(",").map {|sid| Profile.find_by_sid!(sid)}
    profiles.each{|profile| check_profile(profile)}
    profile_ids = profiles.map(&:id)
    render json: {}, status: :bad_request and return if profile_ids.empty?
    @article = Article.new(
      writer_id: @user.id,
      profile_ids: profile_ids,
      title: params[:title],
      content: params[:content]
    )
    @article.id = get_uid(profiles.first.name, params[:title]) if Rails.env.production?
    @article.set_rendering_mode(params[:renderingMode])
    if @article.save
      if params[:files]
        params[:files].each do |file|
          Attachment.create(
            article_id: @article.id,
            uploader_id: @user.id,
            file: file
          )
        end
      end
      render :show, status: :created
    else
      render json: @article.errors, status: :bad_request
    end
  end

  api! "글을 수정한다."
  param :title, String, desc: "글 제목", required: true, empty: false
  param :content, String, desc: "글 내용", required: true, empty: false
  param :renderingMode, ["text", "md"], desc: "글 렌더링 모드(텍스트/markdown/html)", required: true
  param :fileIds, Array, of: Integer, desc: "기존 첨부파일 중 계속 첨부되는 파일의 ID, 여기에 포함되지 않는 파일은 삭제됨", required: false
  param :files, Array, of: File, desc: "새로 추가되는 첨부파일의 목록", required: false
  error code: 401, desc: "자신이 작성하지 않은 글을 수정하려고 하는 경우"
  def update
    @article = Article.find params[:id]
    if @user != @article.writer
      render_unauthorized and return
    end
    @article.set_rendering_mode(params[:renderingMode])
    if @article.update(
      title: params[:title],
      content: params[:content]
    )
      @article.attachments.where.not(id: params[:fileIds]).destroy_all
      if params[:files]
        params[:files].each do |file|
          Attachment.create(
            article_id: @article.id,
            uploader_id: @user.id,
            file: file
          )
        end
      end
      render :show
    else
      render json: @article.errors, status: :bad_request
    end
  end

  api! "글을 삭제한다."
  error code: 401, desc: "자신이 작성하지 않은 글을 삭제하려고 하는 경우"
  def destroy
    @article = Article.find params[:id]
    if @user != @article.writer
      render_unauthorized and return
    end
    @article.attachments.destroy_all
    @article.destroy
    head :no_content
  end

  api! "글에 태그를 추가한다."
  param :tag, String, desc: "추가할 태그", required: true, empty: false
  def add_tag
    @article = Article.find params[:id]
    check_article(@article)
    tag = Tag.create_with(creator_id: @user.id).find_or_create_by(name: params[:tag])
    tag.update_attributes(active: true)
    ArticleTag.create!(
      article_id: @article.id,
      tag_id: tag.id,
      writer_id: @user.id
    )
    @article.reload
    render :show
  end

  api! "글에서 태그를 삭제한다."
  param :tag, String, desc: "삭제할 태그", required: true, empty: false
  def destroy_tag
    @article = Article.find params[:id]
    check_article(@article)
    tag = Tag.find_by_name! params[:tag]
    @article.tags.destroy tag
    tag.check_and_deactivate
    render :show
  end

  api! "글을 추천한다."
  error code: 400, desc: "이미 추천한 글을 다시 추천하려는 경우(1일 1회 제한)"
  def recommend
    @article = Article.find params[:id]
    check_article(@article)
    key = "recommendation:article:#{@article.id}:#{@user.id}"
    if $redis.exists(key)
      render json: {}, status: :bad_request and return
    end
    $redis.set(key, "on")
    expire = DateTime.now.beginning_of_day.to_i + 60 * 60 * 24
    $redis.expireat(key, expire)
    @article.increment(:recommendation_count).save
    render :show
  end

private

  def get_uid(profile_name, title)
    config = Rails.application.config_for(:snucse)
    http = Net::HTTP.new("www.snucse.org", 443)
    http.use_ssl = true
    resp = http.post("/Authentication/Login.aspx", "login_type=member_login&referrer=&redirect_mode=none&member_account=#{config["username"]}&member_password=#{config["password"]}&secure=on")
    cookie = resp["Set-Cookie"]

    subject = "#{profile_name} - #{title}"
    content = "새 스누씨에 글이 등록되었습니다. https://new.snucse.org/"
    resp = http.post("/Board/WriteSubmit.aspx", "subject=#{URI.encode(subject)}&content=#{URI.encode(content)}&render_type=text&action=write&uid=420842&article_uid=&survey_id=&write=ok&is_mine=&is_not_exposed=on&MaxAcceptedFileCount=500", {"Cookie" => cookie})

    resp = http.get("/420842", {"Cookie" => cookie})
    doc = Nokogiri::HTML(resp.body)
    doc.css("#BoardListBody a")[0]["href"][2..-1]
  end
end
