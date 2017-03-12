class Api::V1::SearchController < Api::V1::ApiController
  api! "검색 결과를 전달한다."
  param :q, String, desc: "검색 키워드", required: true
  param :limit, Integer, desc: "검색 결과의 최대 개수, 기본값은 5", required: false
  def index
    q = params[:q]
    limit = params[:limit] || 6
    @articles = Article.search(q).per(limit).records
    comments = Comment.search(q).per(limit).records
    @comments_total = comments.total
    @comments = comments.includes(:article)
    @profiles = Profile.search(q).per(limit).records
    @tags = Tag.search(q).per(limit).records
  end

  api! "글 검색 결과를 전달한다."
  param :q, String, desc: "검색 키워드", required: true
  param :page, Integer, desc: "검색 결과 페이지의 번호, 기본값은 1", required: false
  param :limit, Integer, desc: "검색 결과의 최대 개수, 기본값은 10", required: false
  def article
    q = params[:q]
    page = params[:page] || 1
    limit = params[:limit] || 10
    @articles = Article.search(q).page(page).per(limit).records
  end

  api! "댓글 검색 결과를 전달한다."
  param :q, String, desc: "검색 키워드", required: true
  param :page, Integer, desc: "검색 결과 페이지의 번호, 기본값은 1", required: false
  param :limit, Integer, desc: "검색 결과의 최대 개수, 기본값은 10", required: false
  def comment
    q = params[:q]
    page = params[:page] || 1
    limit = params[:limit] || 10
    comments = Comment.search(q).page(page).per(limit).records
    @comments_total = comments.total
    @comments = comments.includes(:article)
  end

  api! "프로필 검색 결과를 전달한다."
  param :q, String, desc: "검색 키워드", required: true
  param :page, Integer, desc: "검색 결과 페이지의 번호, 기본값은 1", required: false
  param :limit, Integer, desc: "검색 결과의 최대 개수, 기본값은 10", required: false
  def profile
    q = params[:q]
    page = params[:page] || 1
    limit = params[:limit] || 10
    @profiles = Profile.search(q).page(page).per(limit).records
  end

  api! "태그 검색 결과를 전달한다."
  param :q, String, desc: "검색 키워드", required: true
  param :page, Integer, desc: "검색 결과 페이지의 번호, 기본값은 1", required: false
  param :limit, Integer, desc: "검색 결과의 최대 개수, 기본값은 10", required: false
  def tag
    q = params[:q]
    page = params[:page] || 1
    limit = params[:limit] || 10
    @tags = Tag.search(q).page(page).per(limit).records
  end
end
