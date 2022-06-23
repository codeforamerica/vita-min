class CtcController < ApplicationController
  layout "ctc"

  def redirect_locale_home
    redirect_to ctc_root_path(ctc_beta: params[:ctc_beta])
  end

  def set_get_started_link
    I18n.with_locale(locale) do
      @get_started_link = open_for_ctc_intake? ? question_path(id: CtcQuestionNavigation.first) : nil
    end
  end
end
