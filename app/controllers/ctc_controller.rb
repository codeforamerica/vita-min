class CtcController < ApplicationController
  layout "ctc"

  def redirect_locale_home
    redirect_to ctc_root_path, { locale: I18n.locale }
  end
end
