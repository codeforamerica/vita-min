class CtcController < ApplicationController
  layout "ctc"

  def redirect_locale_home
    redirect_to ctc_root_path(ctc_beta: params[:ctc_beta])
  end

  def set_get_started_link
    @get_started_link = open_for_ctc_intake? ? question_path(id: CtcQuestionNavigation.first, locale: locale) : nil
  end
end
