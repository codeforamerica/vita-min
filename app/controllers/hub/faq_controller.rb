module Hub
  class FaqController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "hub"

    def show
      @faq = Content.find_by(id: params[:id])
    end

    def update
      @faq = Content.find_by(id: params[:id])
      if @faq.update(permitted_params)
        flash[:notice] = "FAQ updated."
        redirect_back(fallback_location: hub_faq_path(id: @faq.id))
      else
        flash[:alert] = "Fix errors and try again."
        render :show
      end
    end

    private

    def permitted_params
      params.require(:content).permit(:title_en, :title_es, :body_en, :body_es)
    end
  end
end
