module StateFile
  class AzExciseCreditForm < QuestionsForm
    set_attributes_for :intake,
                       :was_incarcerated,
                       :primary_was_incarcerated,
                       :spouse_was_incarcerated,
                       :ssn_no_employment,
                       :household_excise_credit_claimed,
                       :household_excise_credit_claimed_amt

    validates :ssn_no_employment, inclusion: { in: %w[yes no], message: :blank }
    validates :household_excise_credit_claimed, inclusion: { in: %w[yes no], message: :blank }
    validate :credit_claimed
    validate :incarcerated_columns

    # TODO: stop accepting old column
    def incarcerated_columns
      if was_incarcerated.present?
        return %w[yes no].include?(was_incarcerated)
      else
        if primary_was_incarcerated.blank? || !%w[yes no].include?(primary_was_incarcerated)
          errors.add(:primary_was_incarcerated, I18n.t("errors.messages.blank"))
        end

        if intake.filing_status_mfj?
          if spouse_was_incarcerated.blank? || !%w[yes no].include?(spouse_was_incarcerated)
            errors.add(:spouse_was_incarcerated, I18n.t("errors.messages.blank"))
          end
        end
      end
    end

    # TODO: replace with:
    #  validates_presence_of :household_excise_credit_claimed_amt, if: :household_excise_credit_claimed
    #  validates :household_excise_credit_claimed_amt, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
    def credit_claimed
      if was_incarcerated.blank? && household_excise_credit_claimed == "yes"
        if household_excise_credit_claimed_amt.blank? || household_excise_credit_claimed_amt <= 0 || !household_excise_credit_claimed_amt.is_a?(Integer)
          errors.add(:household_excise_credit_claimed_amt, I18n.t("errors.messages.blank"))
        end
      end
    end

    def save
      attributes = attributes_for(:intake)
      if household_excise_credit_claimed == "no"
        attributes = attributes.merge(household_excise_credit_claimed_amt: nil)
      end
      @intake.update(attributes)
    end
  end
end