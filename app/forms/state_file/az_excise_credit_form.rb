module StateFile
  class AzExciseCreditForm < QuestionsForm
    set_attributes_for :intake, :was_incarcerated, :ssn_no_employment, :household_excise_credit_claimed

    validates :was_incarcerated, inclusion: { in: %w[yes no], message: :blank }
    validates :ssn_no_employment, inclusion: { in: %w[yes no], message: :blank }
    validates :household_excise_credit_claimed, inclusion: { in: %w[yes no], message: :blank }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end