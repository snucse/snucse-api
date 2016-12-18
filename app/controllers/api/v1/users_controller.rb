class Api::V1::UsersController < Api::V1::ApiController
  skip_before_action :check_api_key, only: [:sign_in, :sign_up]
  skip_before_action :check_user_level
  api! "인증 후 access token을 전달한다."
  param :username, String, desc: "사용자의 계정명(아이디)", required: true
  param :password, String, desc: "사용자의 비밀번호", required: true
  error code: 403, desc: "존재하지 않는 계정이거나 비밀번호가 일치하지 않는 경우"
  error code: 419, desc: "가입 승인이 되지 않은 계정인 경우"
  example <<-EOS
  {
    "accessToken": "abcdef0123456789abcdef"
  }
  EOS
  def sign_in
    user = User.where(username: params[:username]).first
    if user and user.check_password(params[:password])
      if user.valid_level?
        api_key = ApiKey.create(
          user_id: user.id
        )
        render json: {
          accessToken: api_key.access_token
        }
      else
        render status: 419, json: {}
      end
    else
      render status: 403, json: {}
    end
  end

  api! "회원 가입을 처리한다."
  param :username, String, desc: "사용할 계정명(아이디)", required: true
  param :password, String, desc: "사용할 비밀번호", required: true
  param :name, String, desc: "사용자의 이름", required: true
  param :birthday, /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/, desc: "생년월일", required: false
  param :bsNumber, /^[0-9]{4}-[0-9]{5}$/, desc: "학번", required: false
  param :phoneNumber, /^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}$/, desc: "전화번호", required: false
  error code: 400, desc: "잘못된 회원 가입 요청"
  def sign_up
    if Profile.where(sid: params[:username]).any?
      render json: {}, status: :bad_request and return
    end
    user = User.new(
      username: params[:username],
      password: params[:password],
      name: params[:name],
      birthday: params[:birthday]
    )
    user.set_information(
      bs_number: params[:bsNumber],
      phone_number: [params[:phoneNumber]]
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

  api! "로그인한 사용자의 정보를 변경한다."
  param :password, String, desc: "사용할 비밀번호", required: false
  param :birthday, /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/, desc: "생년월일", required: false
  param :bsNumber, /^[0-9]{4}-[0-9]{5}$/, desc: "학번", required: false
  param :phoneNumber, /^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}$/, desc: "전화번호", required: false
  def update
    @user.password = params[:password] if params[:password]
    @user.birthday = params[:birthday] if params[:birthday]
    @user.set_information(
      bs_number: params[:bsNumber],
      phone_number: [params[:phoneNumber]]
    )
    @user.save
    render json: {}
  end

  api! "자신의 프로필 이미지를 업로드한다."
  param :image, File, desc: "프로필 이미지", required: true
  error code: 400, desc: "이미지 파일이 아닌 파일을 업로드한 경우"
  def upload_profile_image
    unless params[:image].content_type.start_with? "image"
      render json: {}, status: :bad_request and return
    end
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
