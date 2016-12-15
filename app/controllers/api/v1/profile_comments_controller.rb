class Api::V1::ProfileCommentsController < Api::V1::ApiController
  include AccessControl
  skip_before_action :check_user_level

  api! "프로필 댓글 목록을 전달한다."
  param :profileId, String, desc: "댓글 목록을 가져올 프로필의 ID", required: true
  example <<-EOS
  {
    "profileComments": [
      {
        "id": 1,
        "content": "content",
        "last_reply": {"id": 2, "content": "reply", ...},
        ...
      },
      ...
    ]
  }
  EOS
  def index
    profile = Profile.find_by_sid! params[:profileId]
    check_profile(profile)
    @profile_comments = ProfileComment.where(profile_id: profile.id, parent_comment_id: nil).includes(:writer, :last_reply)
  end

  api! "프로필 댓댓글 목록을 전달한다."
  param :parentCommentId, Integer, desc: "부모 댓글의 ID", required: true
  example <<-EOS
  {
    "comments": [
      {"id": 1, "content": "content", ...},
      ...
    ]
  }
  EOS
  def replies
    profile_comment = ProfileComment.find(params[:parentCommentId])
    check_profile(profile_comment.profile)
    @profile_comments = profile_comment.replies
  end

  api! "프로필 댓글을 조회한다."
  example <<-EOS
  {
    "id": 1,
    "content": "content",
    "recommendationCount": 0,
    "createdAt": {
      "date": "20160801",
      "time": "01:23:45",
      "updated": false
    },
    "writer": {
      "id": 1,
      "username": "writer",
      "name": "작성자",
      "profileImageUri": "http://placehold.it/100x100"
    }
  }
  EOS
  def show
    @profile_comment = ProfileComment.find params[:id]
    check_profile(@profile_comment.profile)
  end

  api! "프로필 댓글을 생성한다."
  param :profileId, String, desc: "댓글이 작성되는 프로필의 ID", required: true
  param :parentCommentId, Integer, desc: "댓댓글인 경우, 부모 댓글의 ID", required: false
  param :content, String, desc: "댓글 내용", required: true
  def create
    profile = Profile.find_by_sid! params[:profileId]
    check_profile(profile)
    @profile_comment = ProfileComment.new(
      writer_id: @user.id,
      profile_id: profile.id,
      parent_comment_id: params[:parentCommentId],
      content: params[:content]
    )
    if @profile_comment.save
      render :show, status: :created
    else
      render json: @profile_comment.errors, status: :bad_request
    end
  end

  api! "프로필 댓글을 수정한다."
  param :content, String, desc: "댓글 내용", required: true
  error code: 401, desc: "자신이 작성하지 않은 프로필 댓글을 수정하려고 하는 경우"
  def update
    @profile_comment = ProfileComment.find params[:id]
    if @user != @profile_comment.writer
      render_unauthorized and return
    end
    if @profile_comment.update(
      content: params[:content]
    )
      render :show
    else
      render json: @profile_comment.errors, status: :bad_request
    end
  end

  api! "프로필 댓글을 삭제한다."
  error code: 401, desc: "자신이 작성하지 않은 프로필 댓글을 삭제하려고 하는 경우"
  def destroy
    @profile_comment = ProfileComment.find params[:id]
    if @user != @profile_comment.writer
      render_unauthorized and return
    end
    @profile_comment.destroy
    head :no_content
  end

  api! "프로필 댓글을 추천한다."
  error code: 400, desc: "이미 추천한 프로필 댓글을 다시 추천하려는 경우(1일 1회 제한)"
  def recommend
    @profile_comment = ProfileComment.find params[:id]
    check_profile(@profile_comment.profile)
    key = "recommendation:profile_comment:#{@profile_comment.id}:#{@user.id}"
    if $redis.exists(key)
      render json: {}, status: :bad_request and return
    end
    $redis.set(key, "on")
    expire = DateTime.now.beginning_of_day.to_i + 60 * 60 * 24
    $redis.expireat(key, expire)
    @profile_comment.increment(:recommendation_count).save
    render json: {}
  end
end
