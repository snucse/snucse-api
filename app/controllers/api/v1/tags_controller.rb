class Api::V1::TagsController < Api::V1::ApiController
  api! "태그 목록을 전달한다."
  param :prefix, String, desc: "설정된 경우 해당 문자열로 시작하는 태그만 전달한다.", required: false
  example <<-EOS
  {
    "tags": [
      {"tag": "tag", "creator": {}},
      ...
    ]
  }
  EOS
  def index
    @tags = Tag.where(active: true).includes(:creator)
    @tags = @tags.where("name like ?", "#{params[:prefix]}%") if params[:prefix]
  end

  api! "최근에 등록된 태그 목록을 전달한다."
  param :offset, Integer, desc: "태그 등록 내역을 검색할 날짜 수, 기본값은 7", required: false
  example <<-EOS
  {
    "tags": [
      {"tag": "tag", "creator": {...}, "count": 123},
      ...
    ]
  }
  EOS
  def recent
    offset = params[:offset].to_i
    offset = 7 if offset == 0
    @tag_count = Hash.new 0
    ArticleTag.where("created_at > ?", Time.now - offset.days).includes(:tag).each do |article_tag|
      @tag_count[article_tag.tag] += 1
    end
    ProfileTag.where("created_at > ?", Time.now - offset.days).includes(:tag).each do |profile_tag|
      @tag_count[profile_tag.tag] += 1
    end
  end

  api! "태그의 정보를 전달한다."
  param :tag, String, desc: "태그", required: true
  example <<-EOS
  {
    "creator": {
      "id": 1,
      "username": "writer",
      "name": "작성자",
      "profileImageUri": "http://placehold.it/100x100"
    },
    "articles": [
      {"id": 1, "title": "title", ...},
      ...
    ],
    "profiles": [
      {"id": 1, "name": "13학번 모임", ...},
      ...
    ],
    "relatedTags": [
      {"tag": "관련태그", "writer": {...}},
      ...
    ]
  }
  EOS
  def show
    @tag = Tag.find_by_name! params[:tag]
  end

  api! "연관 태그를 추가한다."
  param :tag, String, desc: "태그", required: true
  param :relatedTag, String, desc: "추가할 연관 태그", required: true
  def add_related_tag
    @tag = Tag.find_by_name! params[:tag]
    related_tag = Tag.create_with(creator_id: @user.id).find_or_create_by(name: params[:relatedTag])
    TagRelation.create!(
      tag_id: @tag.id,
      related_tag_id: related_tag.id,
      writer_id: @user.id
    )
    TagRelation.create!(
      tag_id: related_tag.id,
      related_tag_id: @tag.id,
      writer_id: @user.id
    )
    @tag.reload
    render :show
  end

  api! "연관 태그를 삭제한다."
  param :tag, String, desc: "태그", required: true
  param :relatedTag, String, desc: "삭제할 연관 태그", required: true
  def destroy_related_tag
    @tag = Tag.find_by_name! params[:tag]
    related_tag = Tag.find_by_name! params[:relatedTag]
    TagRelation.where(
      tag_id: @tag.id,
      related_tag_id: related_tag.id
    ).destroy_all
    TagRelation.where(
      tag_id: related_tag.id,
      related_tag_id: @tag.id
    ).destroy_all
    @tag.reload
    render :show
  end
end
