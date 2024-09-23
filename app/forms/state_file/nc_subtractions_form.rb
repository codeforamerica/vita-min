module StateFile
  class NcSubtractionsForm < QuestionsForm
    set_attributes_for :intake, :tribal_member, :tribal_wages_amount

    validates :tribal_member, inclusion: { in: %w[yes no], message: :blank }
    validates_numericality_of :tribal_wages_amount, if: -> { tribal_member == "yes" }
    validates :tribal_wages_amount, presence: true, allow_blank: false, numericality: { greater_than_or_equal_to: 1 }, if: -> { tribal_member == "yes" }
    validate :below_1040_amount, if: -> { tribal_wages_amount.present? }

    def save
      if tribal_member == "no"
        @intake.update(tribal_member: "no", tribal_wages_amount: nil)
      else
        @intake.update(attributes_for(:intake))
      end
    end

    private

    def below_1040_amount
      amount_limit = @intake.direct_file_data.fed_wages_salaries_tips
      if self.tribal_wages_amount.to_d > amount_limit
        errors.add(:tribal_wages_amount, I18n.t("forms.errors.state_credit.exceeds_limit", limit: amount_limit))
      end
    end
  end
end