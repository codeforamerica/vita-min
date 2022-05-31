module Hub
  class ContentsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "hub"

    def index
      @faq = Content.where(is_faq: true)
      @navigator_page = Content.find_by(name: "navigators")
    end

    def show
      @content = Content.find_by(name: params[:name])
    end

    def update
      @content = Content.find_by(name: params[:name])
      if @content.update(permitted_params)
        flash[:notice] = "Content updated."
        redirect_back(fallback_location: hub_content_path(name: @content.name))
      else
        flash[:alert] = "Fix errors and try again."
        render :show
      end
    end

    private

    def permitted_params
      params.require(:content).permit(:title_en, :title_es, :subtitle_en, :subtitle_es, :body_en, :body_es)
    end
  end
end
