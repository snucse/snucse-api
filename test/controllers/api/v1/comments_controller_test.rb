require 'test_helper'

class Api::V1::CommentsControllerTest < ActionController::TestCase
  test "[comments#list] 필수 parameter가 없는 경우 실패" do
    set_access_token
    get :index
    assert_response :bad_request
  end

  test "[comments#list] 댓글 목록을 가져옴" do
    set_access_token
    article = Article.last
    get :index, articleId: article.id, format: :json
    assert_response :success
    response = JSON.parse @response.body
    assert_equal response["comments"].size, article.comments.size
  end

  test "[comments#show] 특정 댓글을 조회" do
    set_access_token
    comment = Comment.last
    get :show, id: comment.id, format: :json
    assert_response :success
    response = JSON.parse @response.body
    assert_equal response["id"], comment.id
  end

  test "[comments#create] 필수 parameter가 없는 경우 실패" do
    set_access_token
    article = Article.last
    post :create, content: "content"
    assert_response :bad_request
    post :create, article_id: article.id
    assert_response :bad_request
  end

  test "[comments#create] 댓글 생성" do
    set_access_token
    article = Article.last
    content = "contentcontent"
    post :create, articleId: article.id, content: content, format: :json
    assert_response :success
    response = JSON.parse @response.body
    comment = Comment.find(response["id"])
    assert_equal content, comment.content
  end

  test "[comments#update] 존재하지 않는 댓글을 수정하려고 하는 경우 실패" do
    set_access_token
    comment_id = Comment.last.id + 1
    put :update, id: comment_id, content: "content"
    assert_response :not_found
  end

  test "[comments#update] 자신이 작성하지 않은 댓글을 수정하려고 하는 경우 실패" do
    set_access_token
    comment = Comment.create(
      writer: User.last,
      article: Article.last,
      content: "content"
    )
    put :update, id: comment.id, content: "content"
    assert_response :unauthorized
  end

  test "[comments#update] 필수 parameter가 없는 경우 실패" do
    set_access_token
    comment_id = Comment.last.id
    put :update, id: comment_id
    assert_response :bad_request
  end

  test "[comments#update] 댓글 수정" do
    set_access_token
    comment_id = Comment.last.id
    content = "content2"
    put :update, id: comment_id, content: content, format: :json
    assert_response :success
    comment = Comment.find(comment_id)
    assert_equal content, comment.content
  end

  test "[comments#destroy] 존재하지 않는 글을 삭제하려고 하는 경우 실패" do
    comment_id = Comment.last.id + 1
    set_access_token
    delete :destroy, id: comment_id
    assert_response :not_found
  end

  test "[comments#destroy] 자신이 작성하지 않은 글을 삭제하려고 하는 경우 실패" do
    comment = Comment.create(
      writer: User.last,
      article: Article.last,
      content: "content"
    )
    set_access_token
    delete :destroy, id: comment.id
    assert_response :unauthorized
  end

  test "[comments#destroy] 글 삭제" do
    set_access_token
    comment_id = Comment.last.id
    delete :destroy, id: comment_id
    assert_response :success
    assert Comment.where(id: comment_id).empty?
  end
end
