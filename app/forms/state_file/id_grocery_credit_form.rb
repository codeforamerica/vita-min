module StateFile
  class IdGroceryCreditForm < QuestionsForm
    attr_accessor :dependents_attributes
    delegate :dependents, to: :intake

    set_attributes_for(
      :intake,
      :household_has_grocery_credit_ineligible_months,
      :primary_has_grocery_credit_ineligible_months,
      :spouse_has_grocery_credit_ineligible_months,
      :primary_months_ineligible_for_grocery_credit,
      :spouse_months_ineligible_for_grocery_credit
    )

    validates :household_has_grocery_credit_ineligible_months, inclusion: { in: %w[yes no], message: :blank }

    validates :primary_months_ineligible_for_grocery_credit,
              numericality: {
                greater_than_or_equal_to: 0,
                message: :blank
              },
              if: -> { primary_has_grocery_credit_ineligible_months == "yes" }
    validates :spouse_months_ineligible_for_grocery_credit,
              numericality: {
                greater_than_or_equal_to: 0,
                message: :blank
              },
              if: -> { spouse_has_grocery_credit_ineligible_months == "yes" }

    def initialize(intake = nil, params = nil)
      super
      if params.present?
        @intake.assign_attributes(dependents_attributes: dependents_attributes.to_h)
      end
    end

    def save
      attributes_to_save = attributes_for(:intake).merge({ dependents_attributes: dependents_attributes.to_h }).compact
      @intake.update!(attributes_to_save)
    end

    def valid?
      dependents_valid = dependents.map { |d| d.valid?(:id_grocery_credit_form) }
      super && dependents_valid.all?
    end
  end
end
