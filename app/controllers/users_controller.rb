class UsersController < ApplicationController
  include AdminOnly

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path
    else
      render :edit
    end
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path
    else
      render :new
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:notice] = "Permanently deleted #{@user.name}"
    end
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(
      :name, :email, :active, :role
    )
  end
end
