class Api::V1::UsersController < Api::V1::ApiController
  skip_before_action :check_api_key, only: [:sign_in, :sign_up, :show_profile_image]
  skip_before_action :check_user_level
  api! "인증 후 access token을 전달한다."
  param :username, String, desc: "사용자의 계정명(아이디)", required: true
  param :password, String, desc: "사용자의 비밀번호", required: true
  error code: 403, desc: "존재하지 않는 계정이거나 비밀번호가 일치하지 않는 경우"
  example <<-EOS
  {
    "accessToken": "abcdef0123456789abcdef"
  }
  EOS
  def sign_in
    user = User.where(username: params[:username]).first
    if user and user.check_password(params[:password])
      api_key = ApiKey.create(
        user_id: user.id
      )
      render json: {
        accessToken: api_key.access_token
      }
    else
      render status: 403, json: {}
    end
  end

  api! "회원 가입을 처리한다."
  param :username, String, desc: "사용할 계정명(아이디)", required: true
  param :password, String, desc: "사용할 비밀번호", required: true
  param :name, String, desc: "사용자의 이름", required: true
  error code: 400, desc: "잘못된 회원 가입 요청"
  def sign_up
    if Profile.where(sid: params[:username]).any?
      render json: {}, status: :bad_request and return
    end
    user = User.new(
      username: params[:username],
      password: params[:password],
      name: params[:name]
    )
    if user.save
      Profile.create(
        name: params[:name],
        admin_id: user.id,
        description: "",
        sid: params[:username]
      )
      render json: {}
    else
      render json: {}, status: :bad_request
    end
  end

  api! "로그인한 사용자의 정보를 전달한다."
  example <<-EOS
  {
    "id": 1
  }
  EOS
  def me
  end

  api! "프로필 이미지를 조회한다."
  error code: 404, desc: "설정된 프로필 이미지가 없을 때"
  def show_profile_image
    if params[:id] == "me"
      user = @user
    else
      user = User.find params[:id]
    end
    if user.profile_image.file.nil?
      render json: {}, status: :not_found and return
    end
    send_file(user.profile_image.url, disposition: "inline")
  end

  api! "자신의 프로필 이미지를 업로드한다."
  param :image, File, desc: "프로필 이미지", required: true
  def upload_profile_image
    @user.update_attributes(
      profile_image: params[:image]
    )
    render json: {}
  end

  api! "자신의 프로필 이미지를 삭제한다."
  def destroy_profile_image
    @user.remove_profile_image = true
    @user.save
    render json: {}
  end
end
