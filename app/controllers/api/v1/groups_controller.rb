class Api::V1::GroupsController < Api::V1::ApiController
  api! "모임 목록을 전달한다."
  example <<-EOS
  {
    "groups": [
      {"id": 1, "name": "13학번 모임", ...},
      ...
    ]
  }
  EOS
  def index
    @groups = Group.all.includes(:admin)
  end

  api! "자신이 팔로우하고 있는 모임 목록을 전달한다."
  example <<-EOS
  {
    "groups": [
      {"id": 1, "name": "13학번 모임", ...},
      ...
    ]
  }
  EOS
  def following
    @groups = @user.groups
    render action: :index
  end

  api! "모임을 조회한다."
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
    @group = Group.find params[:id]
  end
end
