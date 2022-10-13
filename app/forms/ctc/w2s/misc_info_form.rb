module Ctc
  module W2s
    class MiscInfoForm < W2Form
      set_attributes_for(
        :w2,
        :box11_nonqualified_plans,
        :box12a_code,
        :box12a_value,
        :box12b_code,
        :box12b_value,
        :box12c_code,
        :box12c_value,
        :box12d_code,
        :box12d_value,
        :box13_statutory_employee,
        :box13_retirement_plan,
        :box13_third_party_sick_pay,
      )
      set_attributes_for(
        :w2_box14,
        :other_description,
        :other_amount,
      )
      set_attributes_for(
        :w2_state_fields_group,
        :box15_state,
        :box15_employer_state_id_number,
        :box16_state_wages,
        :box17_state_income_tax,
        :box18_local_wages,
        :box19_local_income_tax,
        :box20_locality_name,
      )

      before_validation_squish(
        :other_description,
        :box15_employer_state_id_number,
        :box20_locality_name
      )

      validates :box11_nonqualified_plans, gyr_numericality: true, allow_blank: true
      validates :box12a_code, allow_blank: true, inclusion: { in: W2::BOX12_OPTIONS }
      validates :box12b_code, allow_blank: true, inclusion: { in: W2::BOX12_OPTIONS }
      validates :box12c_code, allow_blank: true, inclusion: { in: W2::BOX12_OPTIONS }
      validates :box12d_code, allow_blank: true, inclusion: { in: W2::BOX12_OPTIONS }
      validates :box12a_value, gyr_numericality: { greater_than_or_equal_to: 0, message: ->(_object, _data) { I18n.t('views.ctc.questions.w2s.misc_info.box12_value_error') } }, allow_blank: true
      validates :box12b_value, gyr_numericality: { greater_than_or_equal_to: 0, message: ->(_object, _data) { I18n.t('views.ctc.questions.w2s.misc_info.box12_value_error') } }, allow_blank: true
      validates :box12c_value, gyr_numericality: { greater_than_or_equal_to: 0, message: ->(_object, _data) { I18n.t('views.ctc.questions.w2s.misc_info.box12_value_error') } }, allow_blank: true
      validates :box12d_value, gyr_numericality: { greater_than_or_equal_to: 0, message: ->(_object, _data) { I18n.t('views.ctc.questions.w2s.misc_info.box12_value_error') } }, allow_blank: true
      validate :box12s
      validates :other_description, irs_text_type: true, length: { maximum: 100 }, allow_blank: true
      validates :other_amount, gyr_numericality: true, allow_blank: true
      validate :box14
      validates :box15_state, allow_blank: true, inclusion: { in: States.keys }
      validates :box15_employer_state_id_number, irs_text_type: true, length: { maximum: 16 }, allow_blank: true
      validate :box15
      validates :box16_state_wages, gyr_numericality: true, allow_blank: true
      validates :box17_state_income_tax, gyr_numericality: true, allow_blank: true
      validates :box18_local_wages, gyr_numericality: true, allow_blank: true
      validates :box19_local_income_tax, gyr_numericality: true, allow_blank: true
      validates :box20_locality_name, irs_text_type: true, length: { maximum: 20 }, allow_blank: true

      def box12s
        letters = %w(a b c d)
        letters.each do |letter|
          code_field = :"box12#{letter}_code"
          value_field = :"box12#{letter}_value"
          error_field = :"box12#{letter}"
          if send(code_field).present? != send(value_field).present?
            errors.add(error_field, I18n.t('views.ctc.questions.w2s.misc_info.box12_error'))
          end

          if (code_error = errors.delete(code_field))
            errors.add(error_field, code_error)
          end

          if (value_error = errors.delete(value_field))
            errors.add(error_field, value_error)
          end
        end
      end

      def box14
        if other_description.present? != other_amount.present?
          errors.add(:box14, I18n.t('views.ctc.questions.w2s.misc_info.box14_error'))
        end

        if (other_description_error = errors.delete(:other_description))
          errors.add(:box14, other_description_error)
        end

        if (other_amount_error = errors.delete(:other_amount))
          errors.add(:box14, other_amount_error)
        end
      end

      def box15
        if box15_state.present? != box15_employer_state_id_number.present?
          errors.add(:box15, I18n.t('views.ctc.questions.w2s.misc_info.box15_error'))
        end

        if (box15_state_error = errors.delete(:box15_state))
          errors.add(:box15, box15_state_error)
        end

        if (box15_employer_state_id_number_error = errors.delete(:box15_employer_state_id_number))
          errors.add(:box15, box15_employer_state_id_number_error)
        end
      end

      def extra_attributes
        attributes = {
          w2_state_fields_group_attributes: attributes_for(:w2_state_fields_group),
          w2_box14_attributes: attributes_for(:w2_box14),
        }
        if w2.completed_at.nil?
          attributes[:completed_at] = DateTime.now
        end
        attributes
      end

      def self.existing_attributes(w2, _attribute_keys)
        attributes = super
        if w2.w2_state_fields_group.present?
          attributes.merge!(w2.w2_state_fields_group.attributes.except('id', 'w2_id', 'created_at', 'updated_at'))
        end
        if w2.w2_box14.present?
          attributes.merge!(w2.w2_box14.attributes.except('id', 'w2_id', 'created_at', 'updated_at'))
        end
        attributes
      end
    end
  end
end
