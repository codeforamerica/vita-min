module StateFile
  class AzExciseCreditForm < QuestionsForm
    set_attributes_for :intake, :was_incarcerated

    validates :was_incarcerated, inclusion: { in: %w[yes no], message: I18n.t("errors.messages.blank") }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end