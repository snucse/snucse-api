require 'test_helper'

class Api::V1::UsersControllerTest < ActionController::TestCase
  test "[users#sign_up] 필수 parameter가 없는 경우 실패" do
    post :sign_up, password: "password", name: "이름"
    assert_response :bad_request
    post :sign_up, username: "username", name: "이름"
    assert_response :bad_request
    post :sign_up, username: "username", password: "password"
    assert_response :bad_request
  end

  test "[users#sign_up] 이미 가입한 username으로 가입 시도하는 경우 실패" do
    post :sign_up, username: "admin", password: "password", name: "관리자"
    assert_response :bad_request
  end

  test "[users#sign_up] 이미 만들어진 프로필 sid로 가입 시도하는 경우 실패" do
    post :sign_up, username: "_16", password: "_16", name: "16학번"
    assert_response :bad_request
  end

  test "[users#sign_up] 가입 성공 시 프로필 생성" do
    post :sign_up, username: "username", password: "password", name: "가입자"
    assert_response :success
    assert Profile.where(sid: "username").any?
  end

  test "[users#sign_in] 필수 parameter가 없는 경우 실패" do
    post :sign_in, password: "password"
    assert_response :bad_request
    post :sign_in, username: "username"
    assert_response :bad_request
  end

  test "[users#sign_in] 존재하지 않는 username으로 시도하면 실패" do
    post :sign_in, username: "username", password: "password"
    assert_response :forbidden
  end

  test "[users#sign_in] 비밀번호가 틀리면 실패" do
    post :sign_in, username: "admin", password: "password"
    assert_response :forbidden
  end

  test "[users#sign_in] 성공 시 access token을 전달" do
    post :sign_in, username: "admin", password: "admin"
    assert_response :success
    response = JSON.parse @response.body
    api_key = ApiKey.where(access_token: response["access_token"]).first
    assert_not_nil api_key
    assert_equal api_key.user.username, "admin"
    assert_nil api_key.revoked_at
  end
end
