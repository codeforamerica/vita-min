module StateFile
  class TermsAndConditionsForm < QuestionsForm
    set_attributes_for :intake, :consented_to_terms_and_conditions
    validates :consented_to_terms_and_conditions, inclusion: { in: ['yes', 'no'] }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end