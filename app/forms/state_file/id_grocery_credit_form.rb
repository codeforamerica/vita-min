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
      @intake.update!(attributes_to_save)
    end

    def attributes_to_save
      base_attrs = attributes_for(:intake)
      updated_dependent_data = dependents_attributes.select do |k, v|
        month_key = v.keys.include?('id_has_grocery_credit_ineligible_months')
        credit_count_key = v.keys.include?('id_months_ineligible_for_grocery_credit')
        has_matching_yes = dependents_attributes.any? do |k2, v2|
          v['id'] == v2['id'] && v2['id_has_grocery_credit_ineligible_months'] == 'yes'
        end
        month_key || (credit_count_key && has_matching_yes)
      end

      if base_attrs[:household_has_grocery_credit_ineligible_months] == 'no'
        base_attrs.delete :primary_months_ineligible_for_grocery_credit
        base_attrs.delete :spouse_months_ineligible_for_grocery_credit
        updated_dependent_data = {}
      end

      if base_attrs[:primary_has_grocery_credit_ineligible_months] == 'no'
        base_attrs.delete :primary_months_ineligible_for_grocery_credit
      end
      if base_attrs[:spouse_has_grocery_credit_ineligible_months] == 'no'
        base_attrs.delete :spouse_months_ineligible_for_grocery_credit
      end

      base_attrs.merge({ dependents_attributes: updated_dependent_data.to_h }).compact
    end

    def valid?
      dependents_valid = dependents.map { |d| d.valid?(:id_grocery_credit_form) }
      super && dependents_valid.all?
    end
  end
end
