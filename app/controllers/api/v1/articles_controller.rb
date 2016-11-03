class Api::V1::ArticlesController < Api::V1::ApiController
  api! "글 목록을 전달한다."
  param :profileId, String, desc: "설정된 경우 특정 프로필의 글만 전달한다.", required: false
  example <<-EOS
  {
    "articles": [
      {"id": 1, "title": "title", ...},
      ...
    ]
  }
  EOS
  def index
    @articles = Article.all.includes(:profiles, :writer)
    @articles = Profile.find_by_sid!(params[:profileId]).articles.includes(:profiles, :writer) if params[:profileId]
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
    "tags": [
      {"tag": "태그", "writer": {...}},
      ...
    ]
  }
  EOS
  def show
    @article = Article.find params[:id]
  end

  api! "글을 생성한다."
  param :profileIds, String, desc: "글이 작성되는 프로필의 ID, ','로 연결된 문자열 목록", required: true
  param :title, String, desc: "글 제목", required: true
  param :content, String, desc: "글 내용", required: true
  def create
    profile_ids = params[:profileIds].split(",").map {|sid| Profile.find_by_sid!(sid).id}
    render json: {}, status: :bad_request and return if profile_ids.empty?
    @article = Article.new(
      writer_id: @user.id,
      profile_ids: profile_ids,
      title: params[:title],
      content: params[:content]
    )
    if @article.save
      render :show, status: :created
    else
      render json: @article.errors, status: :bad_request
    end
  end

  api! "글을 수정한다."
  param :title, String, desc: "글 제목", required: true
  param :content, String, desc: "글 내용", required: true
  error code: 401, desc: "자신이 작성하지 않은 글을 수정하려고 하는 경우"
  def update
    @article = Article.find params[:id]
    if @user != @article.writer
      render_unauthorized and return
    end
    if @article.update(
      title: params[:title],
      content: params[:content]
    )
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
    @article.destroy
    head :no_content
  end

  api! "글에 태그를 추가한다."
  param :tag, String, desc: "추가할 태그", required: true
  def add_tag
    @article = Article.find params[:id]
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
  param :tag, String, desc: "삭제할 태그", required: true
  def destroy_tag
    @article = Article.find params[:id]
    tag = Tag.find_by_name! params[:tag]
    @article.tags.destroy tag
    tag.check_and_deactivate
    render :show
  end
end
