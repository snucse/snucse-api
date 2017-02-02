class Api::V1::MessagesController < Api::V1::ApiController
  api! "대화 상대 목록을 전달한다."
  example <<-EOS
  {
    "contacts": [
      {"id": 1, "username": "user", "name": "상대방", "profileImageUri": "http://placehold.it/100x100"},
      ...
    ]
  }
  EOS
  def contacts
    @contacts = Contact.where(user_id: @user.id).includes(:contact).map(&:contact)
  end

  DEFAULT_LIMIT = 10
  api! "쪽지 목록을 전달한다."
  param :contactId, String, desc: "쪽지를 주고받은 상대방의 username", required: true
  param :sinceId, Integer, desc: "설정된 경우 ID가 이 값보다 큰 결과만 보낸다.", required: false
  param :maxId, Integer, desc: "설정된 경우 ID가 이 값 이하인 결과만 보낸다.", required: false
  param :limit, Integer, desc: "결과의 최대 개수, 기본값은 10이다.", required: false
  example <<-EOS
  {
    "contact": {
      "id": 1,
      "username": "user",
      "name": "상대방",
      "profileImageUri": "http://placehold.it/100x100"
    },
    "messages": [
      {"id": 1, "senderId": 1, "receiverId": 2, ...},
      ...
    ]
  }
  EOS
  def index
    @contact = User.find_by_username!(params[:contactId])
    limit = params[:limit] || DEFAULT_LIMIT
    @messages = Message.where(sender_id: @user.id, receiver_id: @contact.id).sender_not_deleted.or(Message.where(sender_id: @contact.id, receiver_id: @user.id).receiver_not_deleted).limit(limit)
    @messages = @messages.where("id > ?", params[:sinceId]) if params[:sinceId]
    @messages = @messages.where("id <= ?", params[:maxId]) if params[:maxId]
  end

  api! "쪽지를 생성한다."
  param :contactId, String, desc: "쪽지를 받을 상대방의 username", required: true
  param :content, String, desc: "쪽지 내용", required: true, empty: false
  def create
    contact = User.find_by_username!(params[:contactId])
    @message = Message.new(
      sender_id: @user.id,
      receiver_id: contact.id,
      content: params[:content]
    )
    if @message.save
      Contact.find_or_create_by(user_id: @user.id, contact_id: contact.id)
      Contact.find_or_create_by(user_id: contact.id, contact_id: @user.id)
      render :show, status: :created
    else
      render json: @message.errors, status: :bad_request
    end
  end

  api! "쪽지를 조회한다."
  error code: 401, desc: "자신이 보내거나 받지 않은 쪽지를 조회하려고 하는 경우"
  example <<-EOS
  {
    "id": 1,
    "senderId": 1,
    "receiverId": 2,
    "content": "Hello",
    "createdAt": "2017-01-01T00:00:00.000+09:00"
  }
  EOS
  def show
    @message = Message.find params[:id]
    if @message.sender_id == @user.id
      render json: {}, status: :not_found if @message.sender_deleted?
    elsif @message.receiver_id == @user.id
      render json: {}, status: :not_found if @message.receiver_deleted?
    else
      render_unauthorized and return
    end
  end

  api! "쪽지를 삭제한다."
  error code: 401, desc: "자신이 보내거나 받지 않은 쪽지를 삭제하려고 하는 경우"
  def destroy
    @message = Message.find params[:id]
    if @message.sender_id == @user.id
      @message.destroy_from_sender
    elsif @message.receiver_id == @user.id
      @message.destroy_from_receiver
    else
      render_unauthorized and return
    end
    head :no_content
  end
end
