module StateFile
  class AzStateCreditsForm < QuestionsForm
    set_attributes_for :intake, :tribal_member, :tribal_wages, :armed_forces_member, :armed_forces_wages

    validates :tribal_wages, presence: true, allow_blank: false, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, if: -> { tribal_member == "yes" }
    validates :armed_forces_wages, presence: true, allow_blank: false, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, if: -> { armed_forces_member == "yes" }

    with_options if: -> { tribal_wages.present? || armed_forces_wages.present? } do
      validate :exceeds_1040_amount
    end

    def save
      attributes_to_save = attributes_for(:intake)
      attributes_to_save[:tribal_wages] = nil if tribal_member == "no"
      attributes_to_save[:armed_forces_wages] = nil if armed_forces_member == "no"
      @intake.update(attributes_to_save)
    end

    private

    def exceeds_1040_amount
      amount_limit = @intake.direct_file_data.fed_wages_salaries_tips.to_i
      total = self.tribal_wages.to_i + self.armed_forces_wages.to_i
      if total > amount_limit
        errors.add(:tribal_wages, I18n.t("forms.errors.state_credit.exceeds_limit", limit: amount_limit))
        errors.add(:armed_forces_wages, I18n.t("forms.errors.state_credit.exceeds_limit", limit: amount_limit))
      end
    end
  end
end