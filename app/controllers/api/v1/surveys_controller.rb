class Api::V1::SurveysController < Api::V1::ApiController
  api! "설문조사를 조회한다."
  example <<-EOS
  {
    "id": 1,
    "articleId": 1,
    "title": "설문조사입니다",
    "startTime": "2017-01-01T00:00:00.000+09:00",
    "endTime": "2017-02-01T00:00:00.000+09:00",
    "creator": {
      "id": 1,
      "username": "creator",
      "name": "작성자",
      "profileImageUri": "http://placehold.it/100x100"
    },
    "anonymous": false,
    "voted": true,
    "content": [
      {"question": "하나만 찍으세요", "type": "select-one", "choices": ["1", "2", "3"], "count": [1,2,3]}, // 결과 공개 시
      {"question": "여러 개 찍으세요", "type": "select-many", "choices": ["1", "2", "3"]}, // 결과 비공개 시
      ...
    ]
  }
  EOS
  def show
    @survey = Survey.find params[:id]
  end

  api! "설문조사를 생성한다."
  param :articleId, Integer, desc: "설문조사가 첨부될 글의 ID", required: true
  param :title, String, desc: "설문조사의 제목", required: true
  param :showResultType, ["public", "voter", "finish"], desc: "결과 공개 설정(전체공개/투표자에게 공개/종료 후 공개)", required: true
  param :isAnonymous, ["true", "false"], desc: "익명 설문조사 여부(true/false)", required: true
  param :startTime, /^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$/, desc: "설문조사 시작 시각, 설정하지 않은 경우 현재 시각", required: false
  param :endTime, /^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$/, desc: "설문조사 종료 시각", required: true
  param :content, String, desc: "설문조사의 내용", required: true
  def create
    @survey = Survey.new(
      creator_id: @user.id,
      article_id: params[:articleId],
      title: params[:title],
      start_time: params[:startTime] || DateTime.now,
      end_time: params[:endTime],
      content: params[:content]
    )
    @survey.set_anonymous if params[:isAnonymous] == "true"
    @survey.set_show_result_type(params[:showResultType])
    if @survey.valid_content?
      @survey.save
      render :show, status: :created
    else
      render status: :bad_request, json: {
        errors: "malformed content"
      }
    end
  end

  api! "설문조사를 삭제한다."
  error code: 401, desc: "자신이 작성하지 않은 설문조사를 삭제하려고 하는 경우"
  def destroy
    @survey = Survey.find params[:id]
    if @user != @survey.creator
      render_unauthorized and return
    end
    @survey.destroy
    head :no_content
  end

  api! "설문조사에 투표한다."
  param :content, String, desc: "투표의 내용", required: true
  def vote
    if Vote.where(survey_id: params[:id], voter_id: @user.id).any?
      render status: :bad_request, json: {
        errors: "already voted"
      } and return
    end
    @survey = Survey.find params[:id]
    if @survey.add_vote(params[:content])
      vote = Vote.new(
        survey_id: @survey.id,
        voter_id: @user.id
      )
      vote.content = params[:content] unless @survey.anonymous?
      vote.save
      render :show
    else
      render status: :bad_request, json: {
        errors: "malformed content"
      }
    end
  end
end
