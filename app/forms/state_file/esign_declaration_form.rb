module StateFile
  class EsignDeclarationForm < QuestionsForm
    set_attributes_for :intake,
                       :esigned_return

    validates :esigned_return, acceptance: { accept: 'yes', message: I18n.t("views.ctc.questions.confirm_legal.error") }

    def save
      @intake.update(attributes_for(:intake))
      @intake.touch(:esigned_return_at) if @intake.esigned_return_yes?

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