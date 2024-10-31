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
      updated_dependent_data = dependents_attributes

      # set household member "has months" answers to no if household "has months" answer is no
      if base_attrs[:household_has_grocery_credit_ineligible_months] == 'no'
        base_attrs[:primary_has_grocery_credit_ineligible_months] = 'no'
        base_attrs[:spouse_has_grocery_credit_ineligible_months] = 'no'
        updated_dependent_data = updated_dependent_data.to_h do |k, v|
          if v.key?(:id_has_grocery_credit_ineligible_months)
            [k, v.merge(id_has_grocery_credit_ineligible_months: 'no')]
          else
            [k, v]
          end
        end
      end

      # set household months to nil/0 if their "has months" answer is no
      if base_attrs[:primary_has_grocery_credit_ineligible_months] == 'no'
        base_attrs[:primary_months_ineligible_for_grocery_credit] = ''
      end
      if base_attrs[:spouse_has_grocery_credit_ineligible_months] == 'no'
        base_attrs[:spouse_months_ineligible_for_grocery_credit] = ''
      end

      updated_dependent_data = updated_dependent_data.to_h do |k, v|
        credit_count_key = v.key?(:id_months_ineligible_for_grocery_credit)
        has_matching_no = updated_dependent_data.any? do |_, v2|
          v[:id] == v2[:id] && v2[:id_has_grocery_credit_ineligible_months] == 'no'
        end
        if credit_count_key && has_matching_no
          [k, v.merge(id_months_ineligible_for_grocery_credit: '')]
        else
          [k, v]
        end
      end

      base_attrs.merge({ dependents_attributes: updated_dependent_data.to_h }).compact
    end

    def valid?
      dependents_valid = dependents.map { |d| d.valid?(:id_grocery_credit_form) }
      super && dependents_valid.all?
    end
  end
end
