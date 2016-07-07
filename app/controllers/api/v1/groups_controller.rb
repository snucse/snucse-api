class Api::V1::GroupsController < Api::V1::ApiController
  def index
    @groups = Group.all.includes(:admin)
  end

  def show
    @group = Group.find params[:id]
  end
end
