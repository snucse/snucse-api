class Api::V1::ArticlesController < Api::V1::ApiController
  api! "글 목록을 전달한다."
  param :profile_id, Integer, desc: "설정된 경우 특정 프로필의 글만 전달한다.", required: false
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
    @articles = Profile.find(params[:profile_id]).articles.includes(:profiles, :writer) if params[:profile_id]
  end

  api! "글을 조회한다."
  example <<-EOS
  {
    "id": 1,
    "title": "title",
    "content": "content",
    "created_at": "2016-07-01T00:00:00.000Z",
    "updated_at": "2016-07-01T00:00:00.000Z",
    "profiles": [
      {"id": 1, "name": "13학번 모임"}
    ],
    "writer": {
      "id": 1,
      "username": "writer",
      "name": "작성자",
      "profile_image_url": "http://placehold.it/100x100"
    }
  }
  EOS
  def show
    @article = Article.find params[:id]
  end

  api! "글을 생성한다."
  param :profile_ids, String, desc: "글이 작성되는 프로필의 ID, ','로 연결된 숫자 목록", required: true
  param :title, String, desc: "글 제목", required: true
  param :content, String, desc: "글 내용", required: true
  def create
    profile_ids = params[:profile_ids].split(",")
    if profile_ids.empty? or profile_ids.any? {|x| x !~ /^\d+$/}
      render json: {}, status: :bad_request and return
    end
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
end
