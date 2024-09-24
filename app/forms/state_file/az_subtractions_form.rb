module StateFile
  class AzSubtractionsForm < QuestionsForm
    set_attributes_for :intake, :tribal_member, :tribal_wages, :armed_forces_member, :armed_forces_wages, :tribal_wages_amount, :armed_forces_wages_amount

    validates_numericality_of :tribal_wages, only_integer: true, message: :whole_number, if: -> { tribal_member == "yes" }
    validates :tribal_wages, presence: true, allow_blank: false, numericality: { greater_than_or_equal_to: 1 }, if: -> { tribal_member == "yes" }
    validates_numericality_of :armed_forces_wages, only_integer: true, message: :whole_number, if: -> { armed_forces_member == "yes" }
    validates :armed_forces_wages, presence: true, allow_blank: false, numericality: { greater_than_or_equal_to: 1 }, if: -> { armed_forces_member == "yes" }
    validate :below_1040_amount, if: -> { tribal_wages.present? || armed_forces_wages.present? }

    def save
      attributes_to_save = attributes_for(:intake)

      if tribal_member == "no"
        attributes_to_save[:tribal_wages] = nil
        attributes_to_save[:tribal_wages_amount] = nil
      else
        attributes_to_save[:tribal_wages_amount] = tribal_wages
      end

      if armed_forces_member == "no"
        attributes_to_save[:armed_forces_wages] = nil
        attributes_to_save[:armed_forces_wages_amount] = nil
      else
        attributes_to_save[:armed_forces_wages_amount] = armed_forces_wages
      end

      @intake.update(attributes_to_save)
    end

    private

    def below_1040_amount
      amount_limit = @intake.direct_file_data.fed_wages_salaries_tips
      total = self.tribal_wages.to_i + self.armed_forces_wages.to_i
      if total > amount_limit
        errors.add(:base, I18n.t("forms.errors.state_credit.exceeds_limit", limit: amount_limit))
        errors.add(:tribal_wages, "")
        errors.add(:armed_forces_wages, "")
      end
    end
  end
end