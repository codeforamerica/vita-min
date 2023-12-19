module StateFile
  module StateSpecificQuestionConcern
    # This concern should be used by any controller that asks a state-specific question
    extend ActiveSupport::Concern

    def card_postscript
      I18n.t("state_file.state_file_pages.card_postscript.responses_saved_html").html_safe
    end
  end
end