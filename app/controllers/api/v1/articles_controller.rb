class Api::V1::ArticlesController < Api::V1::ApiController
  def index
    @articles = Article.all.includes(:group, :writer)
  end

  def show
    @article = Article.find params[:id]
  end

  def create
    @article = Article.new(
      writer_id: @user.id,
      group_id: params[:group_id],
      title: params[:title],
      content: params[:content]
    )
    if @article.save
      render :show, status: :created
    else
      render json: @article.errors, status: :bad_request
    end
  end

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
      render json: @article.errors, sttatus: :bad_request
    end
  end

  def destroy
    @article = Article.find params[:id]
    if @user != @article.writer
      render_unauthorized and return
    end
    @article.destroy
    head :no_content
  end
end
