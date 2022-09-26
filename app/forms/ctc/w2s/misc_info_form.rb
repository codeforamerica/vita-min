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

      def save
        extra_attributes = w2.completed_at.nil? ? {completed_at: DateTime.now} : {}
        @w2.assign_attributes(attributes_for(:w2).merge(extra_attributes))
        @w2.save!
      end
    end
  end
end
