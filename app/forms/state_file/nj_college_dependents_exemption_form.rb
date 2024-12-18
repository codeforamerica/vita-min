module StateFile
  class NjCollegeDependentsExemptionForm < QuestionsForm
    attr_accessor :dependents_attributes
    delegate :dependents, to: :intake

    def save
      @intake.update!(dependents_attributes: dependents_attributes.to_h)
    end
  end
end