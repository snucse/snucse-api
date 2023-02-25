class Api::V1::UsersController < Api::V1::ApiController
  include PasswordSync
  skip_before_action :check_api_key, only: [:sign_in, :sign_up]
  skip_before_action :check_user_level
  api! "인증 후 access token을 전달한다."
  param :username, String, desc: "사용자의 계정명(아이디)", required: true, empty: false
  param :password, String, desc: "사용자의 비밀번호", required: true, empty: false
  error code: 403, desc: "존재하지 않는 계정이거나 비밀번호가 일치하지 않는 경우"
  error code: 419, desc: "가입 승인이 되지 않은 계정인 경우"
  example <<-EOS
  {
    "accessToken": "abcdef0123456789abcdef"
  }
  EOS
  def sign_in
    user = User.where(username: params[:username]).first
    if user and check_password(params[:username], params[:password])
      if user.level == 0
        profile = Profile.create(sid: user.username, name: user.name, profile_type: 2, admin_id: user.id, description: "", rendering_mode: 1)
        [4538, 4760, 4761, 4925, 4759].each do |pid|
          Follow.create(user_id: user.id, profile_id: pid)
        end
        Follow.create(user_id: user.id, profile_id: profile.id)
        user.update_attributes(level: 2)
      end
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
  param :username, /^[A-Za-z][A-Za-z0-9]*$/, desc: "사용할 계정명(아이디)", required: true, empty: false
  param :name, String, desc: "사용자의 이름", required: true, empty: false
  param :birthday, /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/, desc: "생년월일", required: false
  param :bsNumber, /^[0-9]{4}-[0-9]{5}$/, desc: "학번", required: false
  param :email, String, desc: "이메일", required: false
  param :phoneNumber, /^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}$/, desc: "전화번호", required: false
  error code: 400, desc: "잘못된 회원 가입 요청"
  def sign_up
    if Profile.where(sid: params[:username]).any? or ReservedWord.where(word: params[:username]).any?
      render json: {}, status: :bad_request and return
    end
    user = User.new(
      username: params[:username],
      name: params[:name],
      birthday: params[:birthday]
    )
    user.set_information(
      bs_number: params[:bsNumber],
      email: params[:email],
      is_email_public: true,
      phone_number: params[:phoneNumber],
      is_phone_number_public: true
    )
    if user.save
      sync_registration(params[:username], params[:name], params[:birthday], params[:bsNumber], params[:email], params[:phoneNumber]) if Rails.env.production?
      render json: {}
    else
      render json: {}, status: :bad_request
    end
  end

  api! "로그인한 사용자의 정보를 전달한다."
  example <<-EOS
  {
    "id": 1,
    "level": 2,
    "name": "사용자",
    "username": "username",
    "profileImageUri": "https://www.snucse.org/files/profile_images/default",
    "renderingMode": "text"
  }
  EOS
  def me
  end

  api! "로그인한 사용자의 비밀번호를 변경한다."
  param :currentPassword, String, desc: "현재 비밀번호", required: true, empty: false
  param :newPassword, String, desc: "새 비밀번호", required: true, empty: false
  def update_password
    unless check_password(@user.username, params[:currentPassword])
      render json: {}, status: :bad_request and return
    end
    sync_password(@user.username, params[:currentPassword], params[:newPassword]) if Rails.env.production?
    render json: {}
  end

  api! "로그인한 사용자의 정보를 변경한다."
  param :birthday, /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/, desc: "생년월일", required: false
  param :bsNumber, /^[0-9]{4}-[0-9]{5}$/, desc: "학번", required: false
  param :email, String, desc: "이메일", required: false
  param :phoneNumber, /^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}$/, desc: "전화번호", required: false
  param :isBirthdayPublic, TrueClass, desc: "생년월일 공개 여부", required: false
  param :isEmailPublic, TrueClass, desc: "이메일 공개 여부", required: false
  param :isPhoneNumberPublic, TrueClass, desc: "전화번호 공개 여부", required: false
  def update
    @user.birthday = params[:birthday] if params[:birthday]
    @user.is_birthday_public = params[:isBirthdayPublic] if params[:isBirthdayPublic]
    is_email_public = if params[:isEmailPublic].nil? then nil else params[:isEmailPublic].to_s == "true" end
    is_phone_number_public = if params[:isPhoneNumberPublic].nil? then nil else params[:isPhoneNumberPublic].to_s == "true" end
    @user.set_information(
      bs_number: params[:bsNumber],
      email: params[:email],
      is_email_public: is_email_public,
      phone_number: params[:phoneNumber],
      is_phone_number_public: is_phone_number_public
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

  api! "생일인 사용자의 목록을 전달한다."
  param :date, /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/, desc: "생일인 사람의 목록을 구하는 날짜, 기본값은 오늘", required: false
  def birthday
    # TODO: 음력 생일 고려하기
    date = params[:date].to_date rescue Date.today
    @users = User.where(is_birthday_public: true, is_birthday_lunar: false).where("MONTH(birthday) = ? and DAYOFMONTH(birthday) = ?", date.month, date.day)
  end
end
