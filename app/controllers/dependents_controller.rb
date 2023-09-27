class DependentsController < ApplicationController
  include AuthenticatedClientConcern

  helper_method :next_path

  before_action do
    redirect_to Questions::DependentsController.to_path_helper(action: :index)
  end

  def index
  end

  def new
  end

  def edit
  end

  def update
  end

  def create
  end

  def destroy
  end
end
