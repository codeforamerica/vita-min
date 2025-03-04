module StateFile
  class AzExciseCreditForm < QuestionsForm
    set_attributes_for :intake,
                       :primary_was_incarcerated,
                       :spouse_was_incarcerated,
                       :household_excise_credit_claimed,
                       :household_excise_credit_claimed_amount

    validates :primary_was_incarcerated, inclusion: { in: %w[yes no], message: :blank }
    validates :spouse_was_incarcerated, inclusion: { in: %w[yes no], message: :blank }, if: -> { intake.filing_status_mfj? }
    validates :household_excise_credit_claimed, inclusion: { in: %w[yes no], message: :blank }
    validates_presence_of :household_excise_credit_claimed_amount, if: -> { household_excise_credit_claimed == "yes" }
    validates :household_excise_credit_claimed_amount, numericality: { greater_than: 0, message: ->(_object, _data) { I18n.t('validators.must_enter_amount') } }, allow_blank: true

    def save
      attributes = attributes_for(:intake)
      if household_excise_credit_claimed == "no"
        attributes = attributes.merge(household_excise_credit_claimed_amount: nil)
      end
      @intake.update(attributes)
    end
  end
end