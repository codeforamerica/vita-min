module StateFile
  class EsignDeclarationForm < QuestionsForm
    set_attributes_for :intake,
                       :primary_esigned,
                       :spouse_esigned

    validates :primary_esigned, acceptance: { accept: 'yes', message: I18n.t("views.ctc.questions.confirm_legal.error") }
    validates :spouse_esigned, acceptance: { accept: 'yes', message: I18n.t("views.ctc.questions.confirm_legal.error") }, if: -> { @intake.filing_status_mfj? }

    def save
      attrs = @intake.filing_status_mfj? ? attributes_for(:intake) : attributes_for(:intake).except(:spouse_esigned)
      @intake.update!(attrs)
      @intake.touch(:primary_esigned_at) if @intake.primary_esigned_yes?
      @intake.touch(:spouse_esigned_at) if @intake.spouse_esigned_yes? && @intake.filing_status_mfj?

      # Submits return
      efile_submission = EfileSubmission.create!(
        data_source: @intake,
      )
      if Rails.env.development? || Rails.env.test?
        efile_submission.transition_to(:preparing)
      end
    end

  end
end