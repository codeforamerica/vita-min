class CtcController < ApplicationController
  layout "ctc"

  def redirect_locale_home
    redirect_to ctc_root_path(ctc_beta: params[:ctc_beta])
  end
end
