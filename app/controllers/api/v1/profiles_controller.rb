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

  api! "프로필을 생성한다."
  param :sid, /^[A-Za-z_][A-Za-z0-9_]*$/, desc: "주소 등에서 쓰일 프로필의 식별자", required: true
  param :name, String, desc: "프로필의 이름", required: true
  param :description, String, desc: "프로필 대문에 표시될 내용", required: true
  def create
    @profile = Profile.new(
      sid: params[:sid],
      name: params[:name],
      admin_id: @user.id,
      description: params[:description]
    )
    if @profile.save
      Follow.create(
        user_id: @user.id,
        profile_id: @profile.id
      )
      @following = true
      render :show, status: :created
    else
      render json: @profile.errors, status: :bad_request
    end
  end

  api! "프로필을 수정한다."
  param :name, String, desc: "프로필의 이름", required: true
  param :description, String, desc: "프로필 대문에 표시될 내용", required: true
  error code: 401, desc: "자신이 관리자가 아닌 프로필을 수정하려고 하는 경우"
  def update
    @profile = Profile.find params[:id]
    if @user != @profile.admin
      render_unauthorized and return
    end
    if @profile.update(
      name: params[:name],
      description: params[:description]
    )
      render :show
    else
      render json: @profile.errors, status: :bad_request
    end
  end

  api! "프로필의 관리자를 다른 사용자로 바꾼다."
  param :admin_id, Integer, desc: "새로운 관리자의 ID", required: true
  error code: 401, desc: "자신이 관리자가 아닌 프로필을 수정하려고 하는 경우"
  def transfer
    @profile = Profile.find params[:id]
    if @user != @profile.admin
      render_unauthorized and return
    end
    if @profile.update(
      admin_id: params[:admin_id]
    )
      render :show
    else
      render json: @profile.errors, status: :bad_request
    end
  end
end
