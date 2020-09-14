class GroupsController < ApplicationController
  include AdminOnly

  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update(group_params)
      redirect_to groups_path
    else
      render :edit
    end
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to groups_path
    else
      render :new
    end
  end

  def destroy
    @group = Group.find(params[:id])
    if @group.destroy
      flash[:notice] = "Permanently deleted #{@group.name}"
    end
    redirect_to groups_path
  end

  private

  def group_params
    params.require(:group).permit(:name, :organization, :description)
  end
end
