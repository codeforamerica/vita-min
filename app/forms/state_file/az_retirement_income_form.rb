module StateFile
  class AzRetirementIncomeForm < QuestionsForm
    set_attributes_for :intake,
                       :received_military_retirement_payment,
                       :received_military_retirement_payment_amount,
                       :primary_received_pension,
                       :primary_received_pension_amount,
                       :spouse_received_pension,
                       :spouse_received_pension_amount

    validates :received_military_retirement_payment_amount, presence: true, numericality: true, allow_blank: false, if: -> { received_military_retirement_payment == "yes" }
    validates :primary_received_pension_amount, presence: true, numericality: true, allow_blank: false, if: -> { primary_received_pension == "yes" }
    validates :spouse_received_pension_amount, presence: true, numericality: true, allow_blank: false, if: -> { spouse_received_pension == "yes" }
    validate :below_1040_amount

    def save
      @intake.update(attributes_for(:intake))
    end

    private

    def below_1040_amount
      amount_limit = @intake.direct_file_data.fed_taxable_pensions
      total = received_military_retirement_payment_amount.to_i + primary_received_pension_amount.to_i + spouse_received_pension_amount.to_i
      if total > amount_limit
        errors.add(:base, I18n.t("forms.errors.state_credit.exceeds_limit", limit: amount_limit))
        errors.add(:received_military_retirement_payment_amount, "")
        errors.add(:primary_received_pension_amount, "")
        errors.add(:spouse_received_pension_amount, "")
      end
    end
  end
end