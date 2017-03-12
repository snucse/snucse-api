class Api::V1::ProfilesController < Api::V1::ApiController
  include AccessControl
  skip_before_action :check_user_level, only: [:following, :show, :add_tag, :destroy_tag]
  api! "그룹 프로필 목록을 전달한다."
  example <<-EOS
  {
    "profiles": [
      {"id": 1, "name": "13학번 모임", ...},
      ...
    ]
  }
  EOS
  def index
    @profiles = Profile.group_profiles.includes(:admin).order(updated_at: :desc)
  end

  DEFAULT_LIMIT = 10
  api! "특정 문자열로 시작하는 프로필 목록을 전달한다."
  param :prefix, String, desc: "검색 대상 문자열", required: true
  param :limit, Integer, desc: "검색 결과의 최대 개수, 기본값은 10", required: false
  def autocomplete
    limit = params[:limit] || DEFAULT_LIMIT
    @profiles = Profile.where("name like ?", "#{params[:prefix]}%").limit(limit)
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
    @follows = @user.follows.includes(profile: :admin)
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
    check_profile(@profile)
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
  param :name, String, desc: "프로필의 이름", required: true, empty: false
  param :description, String, desc: "프로필 대문에 표시될 내용", required: true, empty: false
  param :renderingMode, ["text", "md", "html"], desc: "프로필 대문 렌더링 모드(텍스트/markdown/html)", required: true, empty: false
  def create
    if Profile.where(sid: params[:id]).any? or ReservedWord.where(word: params[:id]).any?
      render json: {}, status: :bad_request and return
    end
    @profile = Profile.new(
      sid: params[:id],
      name: params[:name],
      profile_type: Profile::TYPE_GROUP,
      admin_id: @user.id,
      description: params[:description]
    )
    @profile.set_rendering_mode(params[:renderingMode])
    @user.set_rendering_mode(params[:renderingMode])
    if @profile.save
      Follow.create(
        user_id: @user.id,
        profile_id: @profile.id
      )
      @following = true
      Activity.create(
        actor_id: @user.id,
        profile_id: @profile.id,
        target: @profile,
        action: "create"
      )
      render :show, status: :created
    else
      render json: @profile.errors, status: :bad_request
    end
  end

  api! "프로필을 수정한다."
  param :name, String, desc: "프로필의 이름", required: false, empty: false
  param :description, String, desc: "프로필 대문에 표시될 내용", required: false, empty: false
  param :renderingMode, ["text", "md", "html"], desc: "프로필 대문 렌더링 모드(텍스트/markdown/html)", required: true, empty: false
  error code: 401, desc: "자신이 관리자가 아닌 프로필을 수정하려고 하는 경우"
  def update
    @profile = Profile.find_by_sid! params[:id]
    if @user != @profile.admin
      render_unauthorized and return
    end
    @profile.name = params[:name] if params[:name]
    @profile.description = params[:description] if params[:description]
    @profile.set_rendering_mode(params[:renderingMode])
    @user.set_rendering_mode(params[:renderingMode])
    if @profile.save
      render :show
    else
      render json: @profile.errors, status: :bad_request
    end
  end

  api! "프로필의 관리자를 다른 사용자로 바꾼다."
  param :adminId, String, desc: "새로운 관리자의 ID", required: true, empty: false
  error code: 401, desc: "자신이 관리자가 아닌 프로필을 수정하려고 하는 경우"
  def transfer
    @profile = Profile.find_by_sid! params[:id]
    if @user != @profile.admin
      render_unauthorized and return
    end
    if @profile.user?
      render json: {}, status: :bad_request and return
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
  param :tag, String, desc: "추가할 태그", required: true, empty: false
  def add_tag
    @profile = Profile.find_by_sid! params[:id]
    check_profile(@profile)
    tag = Tag.create_with(creator_id: @user.id).find_or_create_by(name: params[:tag])
    tag.update_attributes(active: true)
    profile_tag = ProfileTag.create!(
      profile_id: @profile.id,
      tag_id: tag.id,
      writer_id: @user.id
    )
    Activity.create(
      actor_id: @user.id,
      profile_id: @profile.id,
      target: profile_tag,
      action: "create"
    )
    @profile.reload
    render :show
  end

  api! "프로필에서 태그를 삭제한다."
  param :tag, String, desc: "삭제할 태그", required: true, empty: false
  def destroy_tag
    @profile = Profile.find_by_sid! params[:id]
    check_profile(@profile)
    tag = Tag.find_by_name! params[:tag]
    profile_tag = ProfileTag.where(profile: @profile, tag: tag).first
    Activity.where(target: profile_tag).destroy_all
    profile_tag.destroy
    tag.check_and_deactivate
    render :show
  end

  api! "팔로우 중인 프로필을 즐겨찾기한다."
  error code: 400, desc: "팔로우 중이 아닌 프로필을 즐겨찾기 시도했거나, 이미 즐겨찾기 중인 프로필인 경우"
  def add_star
    profile_id = Profile.find_by_sid!(params[:id]).id
    follow = Follow.where(user_id: @user.id, profile_id: profile_id).first
    render json: {}, status: :bad_request and return if follow.nil? or follow.star
    follow.update_attributes(star: true)
    render json: {}
  end

  api! "팔로우 중인 프로필을 즐겨찾기 취소한다."
  error code: 400, desc: "팔로우 중이 아닌 프로필을 즐겨찾기 취소 시도했거나, 즐겨찾기 중인 프로필이 아닌 경우, 또는 탭에 등록된 경우"
  def destroy_star
    profile_id = Profile.find_by_sid!(params[:id]).id
    follow = Follow.where(user_id: @user.id, profile_id: profile_id).first
    render json: {}, status: :bad_request and return if follow.nil? or !follow.star or follow.tab
    follow.update_attributes(star: false)
    render json: {}
  end

  MAX_TAB_COUNT = 2
  api! "즐겨찾기 중인 프로필을 탭에 등록한다."
  error code: 400, desc: "팔로우 중이 아니거나 즐겨찾기 중이 아닌 프로필을 등록 시도했거나, 이미 탭에 등록된 프로필인 경우"
  def add_to_tab
    profile_id = Profile.find_by_sid!(params[:id]).id
    follow = Follow.where(user_id: @user.id, profile_id: profile_id).first
    render json: {}, status: :bad_request and return if follow.nil? or !follow.star or follow.tab
    tab_index = Follow.where(user_id: @user.id).where.not(tab: nil).count
    render json: {}, status: :bad_request and return if tab_index >= MAX_TAB_COUNT
    follow.update_attributes(tab: tab_index)
    render json: {}
  end

  api! "탭에 등록된 프로필을 해제한다."
  error code: 400, desc: "팔로우 중이 아닌 프로필을 즐겨찾기 취소 시도했거나, 탭에 등록된 프로필이 아닌 경우"
  def remove_from_tab
    profile_id = Profile.find_by_sid!(params[:id]).id
    follow = Follow.where(user_id: @user.id, profile_id: profile_id).first
    render json: {}, status: :bad_request and return if follow.nil? or follow.tab.nil?
    follow.update_attributes(tab: nil)
    Follow.where(user_id: @user.id).where.not(tab: nil).order(:tab).each_with_index do |follow, i|
      follow.update_attributes(tab: i)
    end
    render json: {}
  end
end
