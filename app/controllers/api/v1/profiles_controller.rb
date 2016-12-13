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
    },
    "tags": [
      {"tag": "태그", "writer": {...}},
      ...
    ]
  }
  EOS
  def show
    @profile = Profile.find_by_sid! params[:id]
    @following = Follow.where(profile_id: @profile.id, user_id: @user.id).any?
  end

  api! "프로필을 팔로우한다."
  def follow
    profile_id = Profile.find_by_sid!(params[:id]).id
    Follow.create(
      user_id: @user.id,
      profile_id: profile_id
    )
    render json: {}
  end

  api! "프로필을 팔로우 취소한다."
  def unfollow
    profile_id = Profile.find_by_sid!(params[:id]).id
    Follow.where(
      user_id: @user.id,
      profile_id: profile_id
    ).destroy_all
    render json: {}
  end

  api! "프로필을 생성한다."
  param :id, /^[A-Za-z_][A-Za-z0-9_]*$/, desc: "주소 등에서 쓰일 프로필의 식별자", required: true
  param :name, String, desc: "프로필의 이름", required: true
  param :description, String, desc: "프로필 대문에 표시될 내용", required: true
  def create
    @profile = Profile.new(
      sid: params[:id],
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
  param :name, String, desc: "프로필의 이름", required: false
  param :description, String, desc: "프로필 대문에 표시될 내용", required: false
  error code: 401, desc: "자신이 관리자가 아닌 프로필을 수정하려고 하는 경우"
  def update
    @profile = Profile.find_by_sid! params[:id]
    if @user != @profile.admin
      render_unauthorized and return
    end
    @profile.name = params[:name] if params[:name]
    @profile.description = params[:description] if params[:description]
    if @profile.save
      render :show
    else
      render json: @profile.errors, status: :bad_request
    end
  end

  api! "프로필의 관리자를 다른 사용자로 바꾼다."
  param :adminId, String, desc: "새로운 관리자의 ID", required: true
  error code: 401, desc: "자신이 관리자가 아닌 프로필을 수정하려고 하는 경우"
  def transfer
    @profile = Profile.find_by_sid! params[:id]
    if @user != @profile.admin
      render_unauthorized and return
    end
    admin = User.find_by_username! params[:adminId]
    if @profile.update(
      admin_id: admin.id
    )
      render :show
    else
      render json: @profile.errors, status: :bad_request
    end
  end

  api! "프로필에 태그를 추가한다."
  param :tag, String, desc: "추가할 태그", required: true
  def add_tag
    @profile = Profile.find_by_sid! params[:id]
    tag = Tag.create_with(creator_id: @user.id).find_or_create_by(name: params[:tag])
    tag.update_attributes(active: true)
    ProfileTag.create!(
      profile_id: @profile.id,
      tag_id: tag.id,
      writer_id: @user.id
    )
    @profile.reload
    render :show
  end

  api! "프로필에서 태그를 삭제한다."
  param :tag, String, desc: "삭제할 태그", required: true
  def destroy_tag
    @profile = Profile.find_by_sid! params[:id]
    tag = Tag.find_by_name! params[:tag]
    @profile.tags.destroy tag
    tag.check_and_deactivate
    render :show
  end
end
