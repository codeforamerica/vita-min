class OrganizationsController < ApplicationController
  include AdminOnly

  def index
    @organizations = Organization.all
  end

  def new
    @organization = Organization.new
  end

  def edit
    @organization = Organization.find(params[:id])
  end

  def update
    @organization = Organization.find(params[:id])
    if @organization.update(organization_params)
      redirect_to organizations_path
    else
      render :edit
    end
  end

  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      redirect_to organizations_path
    else
      render :new
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    if @organization.destroy
      flash[:notice] = "Permanently deleted #{@organization.name}"
    end
    redirect_to organizations_path
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :slug)
  end
end
