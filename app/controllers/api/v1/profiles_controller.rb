class Api::V1::ProfilesController < Api::V1::ApiController
  api! "프로필 목록을 전달한다."
  example <<-EOS
  {
    "profiles": [
      {"id": 1, "name": "13학번 모임", ...},
      ...
    ]
  }
  EOS
  def index
    @profiles = Profile.all.includes(:admin)
  end

  api! "자신이 팔로우하고 있는 프로필 목록을 전달한다."
  example <<-EOS
  {
    "profiles": [
      {"id": 1, "name": "13학번 모임", ...},
      ...
    ]
  }
  EOS
  def following
    @profiles = @user.profiles
    render action: :index
  end

  api! "프로필을 조회한다."
  example <<-EOS
  {
    "id": 1,
    "name": "13학번 모임",
    "admin": {
      "id": 1,
      "username": "admin",
      "name": "관리자"
    }
  }
  EOS
  def show
    @profile = Profile.find params[:id]
    @following = Follow.where(profile_id: @profile.id, user_id: @user.id).any?
  end

  api! "프로필을 팔로우한다."
  def follow
    Follow.create(
      user_id: @user.id,
      profile_id: params[:id]
    )
    render json: {}
  end

  api! "프로필을 팔로우 취소한다."
  def unfollow
    Follow.where(
      user_id: @user.id,
      profile_id: params[:id]
    ).destroy_all
    render json: {}
  end
end
