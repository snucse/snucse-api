require 'test_helper'

class Api::V1::ArticlesControllerTest < ActionController::TestCase
  test "[articles#list] access token 없이 접근하면 실패" do
    get :index
    assert_response :unauthorized
  end

  test "[articles#list] access token이 잘못된 경우 실패" do
    set_incorrect_access_token
    get :index
    assert_response :unauthorized
  end

  test "[articles#list] access token이 유효하지 않은 경우 실패" do
    set_revoked_access_token
    get :index
    assert_response 419
  end

  test "[articles#list] 글 목록을 가져옴" do
    set_access_token
    10.times do
      Profile.all.each do |profile|
        Article.create(
          writer: User.first,
          profiles: [profile],
          title: "title",
          content: "content",
          rendering_mode: 1
        )
      end
    end
    get :index, format: :json
    assert_response :success
  end

  test "[articles#list] 특정 프로필의 글 목록을 가져옴" do
    set_access_token
    10.times do
      Profile.all.each do |profile|
        Article.create(
          writer: User.first,
          profiles: [profile],
          title: "title",
          content: "content",
          rendering_mode: 1
        )
      end
    end
    profile_id = Profile.last.sid
    get :index, profileId: profile_id, format: :json
    assert_response :success
    response = JSON.parse @response.body
    assert response["articles"].all? {|x| x["profiles"].map{|y| y["id"]}.include? profile_id}
  end

  test "[articles#show] 특정 글을 조회" do
    set_access_token
    article = Article.last
    get :show, id: article.id, format: :json
    response = JSON.parse @response.body
    assert_equal response["id"], article.id
  end

  test "[articles#create] 필수 parameter가 없는 경우 실패" do
    set_access_token
    profile_ids = [Profile.last.sid].join(",")
    post :create, title: "title", content: "content", renderingMode: "text"
    assert_response :bad_request
    post :create, profileIds: profile_ids, content: "content", renderingMode: "text"
    assert_response :bad_request
    post :create, profileIds: profile_ids, title: "title", renderingMode: "text"
    assert_response :bad_request
    post :create, profileIds: profile_ids, title: "title", content: "content"
    assert_response :bad_request
  end

  test "[articles#create] 글 생성" do
    set_access_token
    profile_ids = [Profile.last.sid].join(",")
    title = "titletitle"
    content = "contentcontent"
    post :create, profileIds: profile_ids, title: title, content: content, renderingMode: "text", format: :json
    assert_response :success
    response = JSON.parse @response.body
    article = Article.find(response["id"])
    assert_equal title, article.title
    assert_equal content, article.content
  end

  test "[articles#create] 프로필 ID를 지정하지 않은 경우 실패" do
    set_access_token
    post :create, profileIds: "", title: "title", content: "content", renderingMode: "text", format: :json
    assert_response :bad_request
  end

  test "[articles#update] 존재하지 않는 글을 수정하려고 하는 경우 실패" do
    article_id = Article.last.id + 1
    set_access_token
    put :update, id: article_id, title: "title", content: "content", renderingMode: "text"
    assert_response :not_found
  end

  test "[articles#update] 자신이 작성하지 않은 글을 수정하려고 하는 경우 실패" do
    article = Article.create(
      writer: User.last,
      profiles: [Profile.last],
      title: "title",
      content: "content",
      rendering_mode: 1
    )
    set_access_token
    put :update, id: article.id, title: "title", content: "content", renderingMode: "text"
    assert_response :unauthorized
  end

  test "[articles#update] 필수 parameter가 없는 경우 실패" do
    set_access_token
    article_id = Article.last.id
    put :update, id: article_id, content: "content", renderingMode: "text"
    assert_response :bad_request
    put :update, id: article_id, title: "title", renderingMode: "text"
    assert_response :bad_request
    put :update, id: article_id, title: "title", content: "content"
    assert_response :bad_request
  end

  test "[articles#update] 글 수정" do
    set_access_token
    article_id = Article.last.id
    title = "title2"
    content = "content2"
    put :update, id: article_id, title: title, content: content, renderingMode: "text", format: :json
    assert_response :success
    article = Article.find(article_id)
    assert_equal title, article.title
    assert_equal content, article.content
  end

  test "[articles#destroy] 존재하지 않는 글을 삭제하려고 하는 경우 실패" do
    article_id = Article.last.id + 1
    set_access_token
    delete :destroy, id: article_id
    assert_response :not_found
  end

  test "[articles#destroy] 자신이 작성하지 않은 글을 삭제하려고 하는 경우 실패" do
    article = Article.create(
      writer: User.last,
      profiles: [Profile.last],
      title: "title",
      content: "content",
      rendering_mode: 1
    )
    set_access_token
    delete :destroy, id: article.id
    assert_response :unauthorized
  end

  test "[articles#destroy] 글 삭제" do
    set_access_token
    article_id = Article.last.id
    delete :destroy, id: article_id
    assert_response :success
    assert Article.where(id: article_id).empty?
  end
end
