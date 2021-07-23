module Ctc
  class ConfirmLegalForm < QuestionsForm
    set_attributes_for :intake, :consented_to_legal

    validates :consented_to_legal, acceptance: { accept: 'yes', message: I18n.t("views.ctc.questions.confirm_legal.error") }

    def save
      @intake.update(attributes_for(:intake))
      unless @intake.tax_returns.last.efile_submissions.any?
        EfileSubmission.create(tax_return: @intake.tax_returns.last).transition_to(:preparing)
      end
    end
  end
end