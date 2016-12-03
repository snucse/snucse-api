class Api::V1::CommentsController < Api::V1::ApiController
  include AccessControl
  skip_before_action :check_user_level

  api! "댓글 목록을 전달한다."
  param :articleId, Integer, desc: "댓글 목록을 가져올 글의 ID", required: true
  example <<-EOS
  {
    "comments": [
      {"id": 1, "content": "content", ...},
      ...
    ]
  }
  EOS
  def index
    article = Article.find(params[:articleId])
    check_article(article)
    @comments = Comment.where(article_id: params[:articleId]).includes(:writer)
  end

  api! "댓글을 조회한다."
  example <<-EOS
  {
    "id": 1,
    "content": "content",
    "recommendationCount": 0,
    "createdAt": {
      "date": "20160801",
      "time": "01:23:45",
      "updated": false
    },
    "writer": {
      "id": 1,
      "username": "writer",
      "name": "작성자",
      "profileImageUri": "http://placehold.it/100x100"
    }
  }
  EOS
  def show
    @comment = Comment.find params[:id]
    check_comment(@comment)
  end

  api! "댓글을 생성한다."
  param :articleId, Integer, desc: "댓글이 작성되는 글의 ID", required: true
  param :content, String, desc: "댓글 내용", required: true
  def create
    article = Article.find(params[:articleId])
    check_article(article)
    @comment = Comment.new(
      writer_id: @user.id,
      article_id: params[:articleId],
      content: params[:content]
    )
    if @comment.save
      render :show, status: :created
    else
      render json: @comment.errors, status: :bad_request
    end
  end

  api! "댓글을 수정한다."
  param :content, String, desc: "댓글 내용", required: true
  error code: 401, desc: "자신이 작성하지 않은 댓글을 수정하려고 하는 경우"
  def update
    @comment = Comment.find params[:id]
    if @user != @comment.writer
      render_unauthorized and return
    end
    if @comment.update(
      content: params[:content]
    )
      render :show
    else
      render json: @comment.errors, status: :bad_request
    end
  end

  api! "댓글을 삭제한다."
  error code: 401, desc: "자신이 작성하지 않은 댓글을 삭제하려고 하는 경우"
  def destroy
    @comment = Comment.find params[:id]
    if @user != @comment.writer
      render_unauthorized and return
    end
    @comment.destroy
    head :no_content
  end

  api! "댓글을 추천한다."
  error code: 400, desc: "이미 추천한 댓글을 다시 추천하려는 경우(1일 1회 제한)"
  def recommend
    @comment = Comment.find params[:id]
    key = "recommendation:comment:#{@comment.id}:#{@user.id}"
    if $redis.exists(key)
      render json: {}, status: :bad_request and return
    end
    $redis.set(key, "on")
    expire = DateTime.now.beginning_of_day.to_i + 60 * 60 * 24
    $redis.expireat(key, expire)
    @comment.increment(:recommendation_count).save
    render json: {}
  end
end
