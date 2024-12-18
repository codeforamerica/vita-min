module StateFile
  class AzSubtractionsForm < QuestionsForm
    set_attributes_for :intake, :tribal_member, :armed_forces_member, :tribal_wages_amount, :armed_forces_wages_amount

    validates :tribal_wages_amount, presence: true, allow_blank: false, numericality: { greater_than_or_equal_to: 1 }, if: -> { tribal_member == "yes" }
    validates :armed_forces_wages_amount, presence: true, allow_blank: false, numericality: { greater_than_or_equal_to: 1 }, if: -> { armed_forces_member == "yes" }
    validate :below_1040_amount, if: -> { tribal_wages_amount.present? || armed_forces_wages_amount.present? }

    def save
      attributes_to_save = attributes_for(:intake)
      attributes_to_save[:tribal_wages_amount] = nil if tribal_member == "no"
      attributes_to_save[:armed_forces_wages_amount] = nil if armed_forces_member == "no"
      @intake.update(attributes_to_save)
    end

    private

    def below_1040_amount
      amount_limit = @intake.direct_file_data.fed_wages_salaries_tips
      total = self.tribal_wages_amount.to_d.round + self.armed_forces_wages_amount.to_d.round
      if total > amount_limit
        errors.add(:base, I18n.t("forms.errors.state_credit.exceeds_limit", limit: amount_limit))
        errors.add(:tribal_wages_amount, "")
        errors.add(:armed_forces_wages_amount, "")
      end
    end
  end
end